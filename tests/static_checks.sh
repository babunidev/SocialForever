#!/usr/bin/env bash
set -euo pipefail

echo "Checking TOC interface and referenced runtime files..."
grep -Eq '^## Interface:[[:space:]]*16001[[:space:]]*$' SocialForever.toc

echo "Checking release version consistency..."
toc_version="$(sed -n 's/^## Version:[[:space:]]*//p' SocialForever.toc | head -n1)"
[[ -n "$toc_version" ]] || { echo "Missing TOC version" >&2; exit 1; }
grep -Fq "Current version: **$toc_version**" README.md
grep -Fq "## $toc_version" CHANGELOG.md

while IFS= read -r f; do
  [[ -f "$f" ]] || { echo "Missing TOC runtime file: $f" >&2; exit 1; }
done < <(awk '!/^#/ && /\.lua$/' SocialForever.toc)

echo "Checking removed auto-invite runtime symbols..."
runtime_files=(Core.lua Memory.lua Group.lua Detection.lua Sharing.lua UI.lua Events.lua)
matches="$(grep -niE 'autoInviteFriends|sameMobAutoInvite|sameMobApiInvite|TryAutoInvite|FriendsAutoOn|SameMobAutoOn|SetSameMobAuto|InviteByKey' "${runtime_files[@]}" || true)"
unexpected="$(printf '%s\n' "$matches" | grep -vE '^Core\.lua:[0-9]+:[[:space:]]*db\.(autoInviteFriends|sameMobAutoInvite)[[:space:]]*=[[:space:]]*nil[[:space:]]*$' || true)"

if [[ -n "$unexpected" ]]; then
  echo "Unexpected removed/automatic invite runtime references:" >&2
  printf '%s\n' "$unexpected" >&2
  exit 1
fi

echo "Checking later-client race/class leftovers..."
if grep -nE 'Draenei|BloodElf|DEATHKNIGHT' Core.lua; then
  echo "Later-client race/class symbol remains in Core.lua" >&2
  exit 1
fi

echo "Checking periodic sorting ticker..."
grep -Fq 'C_Timer.NewTicker(C.SORT_EVERY, UI.RefreshSortOrder)' Events.lua

echo "Checking combat-lockdown overlay and post-combat repaint..."
grep -Fq 'function UI.RefreshCombatList()' UI.lua
grep -Fq 'UI.RefreshCombatList()' UI.lua
grep -Fq 'S.listDirty = true' UI.lua
grep -Fq 'if S.listDirty and UI.RefreshList then' Events.lua
grep -Fq 'UI.RefreshList({ force = true, skipMove = true })' Events.lua

echo "Checking protected-row combat shield..."
grep -Fq 'RegisterStateDriver(shield, "visibility", "[combat] show; hide")' UI.lua
grep -Fq 'UI.EnsureCombatShield(row)' UI.lua

echo "Checking deliberate combat invite path..."
grep -Fq 'local invite = C_PartyInfo and C_PartyInfo.InviteUnit' UI.lua
grep -Fq 'if self.key and UI.DirectInvite(self.key) then' UI.lua
direct_invite_refs="$(grep -c 'UI.DirectInvite' UI.lua)"
[[ "$direct_invite_refs" -eq 2 ]] || { echo "Unexpected UI.DirectInvite call count: $direct_invite_refs" >&2; exit 1; }

echo "Checking combat-safe interaction fallback..."
grep -Fq 'type(InCombatLockdown) == "function" and InCombatLockdown()' Core.lua

echo "Checking CurseForge packaging metadata..."
grep -Eq '^package-as:[[:space:]]+SocialForever[[:space:]]*$' .pkgmeta
for ignored in '.github' 'tests' 'AGENTS.md' 'CONCEPT.md' 'DEVELOPMENT.md' 'ROADMAP.md' 'docs'; do
  grep -Fq "  - $ignored" .pkgmeta
done

echo "PASS: static source and manifest checks"

echo "Checking activity detection sources..."
grep -Fq 'Detection.NoteCraftEvent(arg1, arg2, select(12, ...), false)' Events.lua
grep -Fq 'Detection.NoteCraftEvent(arg1, arg2, select(12, ...), true)' Events.lua
if grep -Fq 'Detection.ScanCombatLog' Events.lua; then
  echo "Legacy Combat Log polling remains registered" >&2
  exit 1
fi
if grep -Fq 'CHAT_MSG_SKILL' Events.lua; then
  echo "CHAT_MSG_SKILL should not be used as nearby craft evidence" >&2
  exit 1
fi

echo "Checking current-sighting provenance wiring..."
grep -Fq 'origins = seen.origins' Detection.lua
grep -Fq 'Nearby because:' UI.lua
grep -Fq 'C.ORIGIN_LABELS' Core.lua

echo "Checking recognition/list synchronization..."
grep -Fq 'not Memory.RecognitionCurrentlyNearby(key)' Memory.lua
grep -Fq 'pcall(Detection.ConsiderUnit, "target", true, "target")' Memory.lua
grep -Fq 'Memory.FlushRecognitionAfterCombat()' Events.lua

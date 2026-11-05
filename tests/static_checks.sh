#!/usr/bin/env bash
set -euo pipefail

echo "Checking TOC interface and referenced runtime files..."
grep -Eq '^## Interface:[[:space:]]*16001[[:space:]]*

while IFS= read -r f; do
  [[ -f "$f" ]] || { echo "Missing TOC runtime file: $f" >&2; exit 1; }
done < <(awk '!/^#/ && /\.lua$/' SocialForever.toc)

echo "Checking removed auto-invite runtime symbols..."
runtime_files=(Core.lua Memory.lua Group.lua Detection.lua Sharing.lua UI.lua Events.lua)
matches="$(grep -niE 'autoInviteFriends|sameMobAutoInvite|sameMobApiInvite|TryAutoInvite|FriendsAutoOn|SameMobAutoOn|SetSameMobAuto|InviteByKey|InviteUnit' "${runtime_files[@]}" || true)"
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

echo "Checking combat-lockdown deferred list repaint..."
grep -Fq 'if InCombatLockdown() then' UI.lua
grep -Fq 'S.listDirty = true' UI.lua
grep -Fq 'if S.listDirty and UI.RefreshList then' Events.lua
grep -Fq 'UI.RefreshList({ force = true, skipMove = true })' Events.lua

echo "Checking combat-safe interaction fallback..."
grep -Fq 'type(InCombatLockdown) == "function" and InCombatLockdown()' Core.lua

echo "Checking CurseForge packaging metadata..."
grep -Eq '^package-as:[[:space:]]+SocialForever[[:space:]]*$' .pkgmeta
for ignored in '.github' 'tests' 'AGENTS.md' 'CONCEPT.md' 'DEVELOPMENT.md' 'ROADMAP.md' 'docs'; do
  grep -Fq "  - $ignored" .pkgmeta
done

echo "PASS: static source and manifest checks"
 SocialForever.toc

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
matches="$(grep -niE 'autoInviteFriends|sameMobAutoInvite|sameMobApiInvite|TryAutoInvite|FriendsAutoOn|SameMobAutoOn|SetSameMobAuto|InviteByKey|InviteUnit' "${runtime_files[@]}" || true)"
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

echo "Checking combat-lockdown deferred list repaint..."
grep -Fq 'if InCombatLockdown() then' UI.lua
grep -Fq 'S.listDirty = true' UI.lua
grep -Fq 'if S.listDirty and UI.RefreshList then' Events.lua
grep -Fq 'UI.RefreshList({ force = true, skipMove = true })' Events.lua

echo "Checking combat-safe interaction fallback..."
grep -Fq 'type(InCombatLockdown) == "function" and InCombatLockdown()' Core.lua

echo "Checking CurseForge packaging metadata..."
grep -Eq '^package-as:[[:space:]]+SocialForever[[:space:]]*$' .pkgmeta
for ignored in '.github' 'tests' 'AGENTS.md' 'CONCEPT.md' 'DEVELOPMENT.md' 'ROADMAP.md' 'docs'; do
  grep -Fq "  - $ignored" .pkgmeta
done

echo "PASS: static source and manifest checks"

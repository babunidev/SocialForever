#!/usr/bin/env bash
set -euo pipefail

LUAC_BIN="${LUAC_BIN:-luac}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PKG="$TMP/SocialForever"
EXTRACT="$TMP/extracted"
ZIP="$TMP/SocialForever-ci.zip"

mkdir -p "$PKG" "$EXTRACT"

runtime=(
  SocialForever.toc
  Core.lua
  Memory.lua
  Group.lua
  Detection.lua
  Sharing.lua
  UI.lua
  Events.lua
)

docs=(
  README.md
  CHANGELOG.md
  LICENSE
)

for f in "${runtime[@]}" "${docs[@]}"; do
  [[ -f "$f" ]] || { echo "Required package file missing: $f" >&2; exit 1; }
  cp "$f" "$PKG/"
done

echo "Package contents:"
find "$PKG" -maxdepth 1 -type f -printf '%f\n' | sort

if find "$PKG" \( -path '*/tests/*' -o -path '*/.github/*' -o -name '.DS_Store' -o -name '*.swp' -o -name '*~' -o -name '*.env' \) -print | grep -q .; then
  echo "Unwanted development/editor file found in package" >&2
  exit 1
fi

if grep -RIE -- '-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|https://(discord|discordapp)\.com/api/webhooks/' "$PKG"; then
  echo "Possible credential or secret found in package" >&2
  exit 1
fi

(
  cd "$TMP"
  zip -qr "$ZIP" SocialForever
)

unzip -q "$ZIP" -d "$EXTRACT"
cd "$EXTRACT/SocialForever"

for f in Core.lua Memory.lua Group.lua Detection.lua Sharing.lua UI.lua Events.lua; do
  "$LUAC_BIN" -p "$f"
done

while IFS= read -r f; do
  [[ -f "$f" ]] || { echo "Packaged TOC references missing file: $f" >&2; exit 1; }
done < <(awk '!/^#/ && /\.lua$/' SocialForever.toc)

echo "PASS: clean package, ZIP re-extraction, Lua syntax, and TOC integrity"

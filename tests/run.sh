#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -z "${LUA_BIN:-}" ]]; then
  if command -v lua5.4 >/dev/null 2>&1; then
    LUA_BIN=lua5.4
  else
    LUA_BIN=lua
  fi
fi

if [[ -z "${LUAC_BIN:-}" ]]; then
  if command -v luac5.4 >/dev/null 2>&1; then
    LUAC_BIN=luac5.4
  else
    LUAC_BIN=luac
  fi
fi

echo "== Lua syntax =="
for f in Core.lua Memory.lua Group.lua Detection.lua Sharing.lua UI.lua Events.lua; do
  echo "Checking $f"
  "$LUAC_BIN" -p "$f"
done

echo "== Lua mock tests =="
for test_file in tests/test_*.lua; do
  echo "-- $test_file"
  "$LUA_BIN" "$test_file"
done

echo "== Static checks =="
bash tests/static_checks.sh

echo "== Package integrity =="
LUAC_BIN="$LUAC_BIN" bash tests/package_check.sh

echo "PASS: all automated/local pre-release verification checks"

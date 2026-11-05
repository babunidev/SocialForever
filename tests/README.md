# Automated pre-release verification

These tests exercise deterministic Social Forever behavior outside the World of Warcraft: Forever client.

They cover Lua syntax, SavedVariables migration, identity icons, familiarity and recognition, memory reset, raid proximity and API-call counts, sorting, Nearby/Zone separation, nearby craft-event parsing, current-sighting provenance, combat-time ordinary-list/invite consistency, same-mob prompt safety, sharing privacy, player-name normalization, static cleanup, TOC references, and package integrity.

Run the same suite locally with:

```bash
bash tests/run.sh
```

The scripts use `lua5.4` / `luac5.4` when available and otherwise fall back to `lua` / `luac`.

## Verification boundary

Passing these tests means **automated/local mock verification only**. They do not prove live Forever event behavior, secure/combat restrictions, secret values, client distance semantics, real addon messaging, or any other behavior that requires the actual Forever client.

Live results must be documented separately after in-game testing.

# SocialForever — architecture

**Human creative:** Babuni

Core.lua, Detection.lua, Events.lua, Group.lua, Memory.lua, Sharing.lua and UI.lua organize proximity signals, encounter persistence, party ratings, sharing and list display; README and DEVELOPMENT.md provide detailed behavior.

These are code/file observations. Read current README and CHANGELOG for detailed configuration and releases.

## Architecture and behavior boundaries — audit #32

`SocialForever.toc` declares Interface **16001**, version **0.4.8-beta**, account-wide `SocialForeverDB`, and load order `Core.lua → Memory.lua → Group.lua → Detection.lua → Sharing.lua → UI.lua → Events.lua`. The 0.3.0 development entry records the split from a large monolithic Lua file without intending a player-facing behavior change.

`Core.lua` exposes the shared `SocialForever` namespace and constants, including a 50-yard nearby threshold, 180-second sighting TTL, three-second sort interval and 1200-second recognition cooldown. `Detection.lua` gathers varied partial clues while `Memory.lua` maintains records and derives familiarity. `UI.lua` presents a user-stable, target-pinned list. `Sharing.lua` has conservative whisper eligibility for Forever's two-part player names; the v0.4.4 wire format keeps an empty legacy flag slot and sends only marks. `Group.lua` and `Events.lua` connect grouping and runtime events.

The [0.4.2 release entry](../DEVELOPMENT.md) records that a nominally successful protected invite API call need not mean an invitation was actually sent; secure send-path verification is necessary before showing an invited state. Zone roster membership alone must not be interpreted as a distance measurement. This description is static source inspection, not a run of the game client.

## Secure list-row boundary

The player rows and Invite controls use `SecureActionButtonTemplate` so targeting and invitations remain deliberate hardware-driven actions. Their geometry and visibility are therefore treated as combat-locked state: `UI.RefreshList` defers row repainting while `InCombatLockdown()` is true, and `PLAYER_REGEN_ENABLED` flushes any dirty list state afterward. Detection and SavedVariables updates are not paused by this presentation guard.

## Protected range-query boundary

`Util.Interact` wraps `CheckInteractDistance` only out of combat. On the live Forever client, calling that API from SocialForever during combat can raise `ADDON_ACTION_BLOCKED`; `pcall` cannot suppress the protected-action event. During combat the helper returns no interaction-range evidence, leaving exact `UnitDistanceSquared` results and ordinary visible-unit fallback logic to drive detection.

## Nearby activity evidence

Crafting and combat are separate evidence families. Ordinary trade-skill craft announcements may arrive through `CHAT_MSG_TRADESKILLS` or craft-shaped `CHAT_MSG_SYSTEM` lines; SocialForever prefers the event GUID/sender and uses Blizzard's localized third-person craft strings only as a fallback parser. `CHAT_MSG_SKILL` is not treated as nearby-player evidence because it primarily reports the local character's skill gains.

Forever intentionally protects Combat Log text from addon parsing, so SocialForever does not poll or parse the Combat Log chat frame. Combat-related Nearby discovery instead uses unit tokens/nameplates/interactions while they exist and `C_DamageMeter` after combat when another player is present in the same recorded session. Skinning is gathering, not ordinary crafting, and currently has no verified direct nearby-player event path.

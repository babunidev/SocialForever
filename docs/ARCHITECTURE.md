# SocialForever — architecture

**Author:** Babuni.dev

Core.lua, Detection.lua, Events.lua, Group.lua, Memory.lua, Sharing.lua and UI.lua organize proximity signals, encounter persistence, party ratings, sharing and list display; README and DEVELOPMENT.md provide detailed behavior.

These are code/file observations. Read current README and CHANGELOG for detailed configuration and releases.

## Architecture and behavior boundaries — audit #32

`SocialForever.toc` declares Interface **16001**, version **0.4.6-beta**, account-wide `SocialForeverDB`, and load order `Core.lua → Memory.lua → Group.lua → Detection.lua → Sharing.lua → UI.lua → Events.lua`. The 0.3.0 development entry records the split from a large monolithic Lua file without intending a player-facing behavior change.

`Core.lua` exposes the shared `SocialForever` namespace and constants, including a 50-yard nearby threshold, 180-second sighting TTL, three-second sort interval and 1200-second recognition cooldown. `Detection.lua` gathers varied partial clues while `Memory.lua` maintains records and derives familiarity. `UI.lua` presents a user-stable, target-pinned list. `Sharing.lua` has conservative whisper eligibility for Forever's two-part player names; the v0.4.4 wire format keeps an empty legacy flag slot and sends only marks. `Group.lua` and `Events.lua` connect grouping and runtime events.

The [0.4.2 release entry](../DEVELOPMENT.md) records that a nominally successful protected invite API call need not mean an invitation was actually sent; secure send-path verification is necessary before showing an invited state. Zone roster membership alone must not be interpreted as a distance measurement. This description is static source inspection, not a run of the game client.

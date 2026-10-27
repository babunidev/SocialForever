# SocialForever — development journal

**Author:** Babuni.dev

## Retrospective reconstruction — 2026-10-26

A World of Warcraft: Forever social-memory addon that remembers recurring nearby players and makes recognizing, inviting, marking and rating them easier. The repository material shows a concrete approach: Core.lua, Detection.lua, Events.lua, Group.lua, Memory.lua, Sharing.lua and UI.lua organize proximity signals, encounter persistence, party ratings, sharing and list display; README and DEVELOPMENT.md provide detailed behavior. It seeks familiarity rather than a constant automated nameplate layer; it works with nameplates switched off, preserves account-wide encounter history and offers subjective personal marks. Shared marks require caution in social presentation.

Earlier release details are preserved in the existing changelog and, where available, development notes. This entry does not substitute a fictional conversation chronology. Babuni.dev retains original design credit; AI contributed analysis and documentation, not the idea or in-game test. Review detection-source false positives, large-local-population behavior, invite prompts, group review, sharing privacy and SavedVariables migrations in-game.

## 2026-10-27 — Audit #32: remembering people, not measuring them

SocialForever began from a social problem: playing without nameplates can make the world feel anonymous even when the same people repeatedly share quests and roads. Babuni.dev wanted encounters to become recognizable and invitations to be easier. The development log reveals how that simple motive accumulated difficult edge cases. The list needed to remain steady under the mouse rather than reorder before a click; a General-zone name could not automatically mean a person was physically nearby; and a protected invitation API could appear to succeed without sending anything.

Several revisions sharpened the addon rather than expanding its surface. Version 0.3.0 divided the large implementation into seven cooperating Lua modules. Version 0.3.1 protected selection through temporary list freezing and target priority. Version 0.4.1 split Nearby from Zone and added opt-in shared-mob group formation. Version 0.4.2 corrected misleading invited-state feedback. Version 0.4.4 kept personal flags private even when color marks were exchanged with peers. Version 0.4.5 introduced the small familiar-player thought: a race/class sentence after encountering a familiar eligible character, restrained by a persistent per-player cooldown. Version 0.4.6 removed empty tooltip clutter.

**Creator direction:** A more attentive, socially legible world, not an intrusive scanning interface. **AI contribution in this audit:** Source-based consolidation and navigational documentation, not original authorship of the idea. **Verification:** Read the README, TOC, selected modules, DEVELOPMENT and CHANGELOG; did not run the addon, transmit peer marks, attempt real invites or access private player records. Original release documents remain unchanged.

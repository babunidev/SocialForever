# Social Forever — Changelog

## Unreleased

- Separated confirmed party-roster membership from online presence. Disconnected members remain in the party-review snapshot while their online Nearby presence can expire normally.
- Added Forever's `UNIT_CONNECTION` event to refresh connection state without treating an offline/online transition as a party departure.
- Party unit tokens must pass `UnitInParty` before they can enter group history or a group-rating snapshot, excluding pending or declined invitations.
- Added mock regression coverage for disconnect/reconnect, a non-member invite candidate, and a confirmed leave/removal. Live Forever verification remains required.

## 0.4.9-beta — 2026-11-05

- Battleground familiarity now counts each encountered player only once per match, independent of respawns, graveyards, subzones and reloads. A persisted character-specific match token allows a later battleground match to count again after a confirmed exit; normal-world subzone counting stays unchanged. Mock regression added; live Forever validation pending.

- Simplified Nearby tooltip provenance to one reason: targeting and hovering display **Mouseover**, while a detected helpful buff displays **Buff**. The complete ephemeral origin set remains available internally.

- Restored event-driven instant mouseover presentation without waiting for the half-second scan or a moving-row transition.
- Helpful aura caster GUIDs from freshly added buffs no longer require a currently targetable unit token; recent identified buff casters receive temporary top-list priority, beneath the currently targeted player.
- Empty aura deltas fall back to scanning readable helpful auras. These paths require live Forever verification, especially with secret aura values in combat.

- Restored immediate Nearby presentation during combat without mutating protected target rows. Mouseover/target/nameplate and other usable detections now paint into a separate normal-frame combat overlay as soon as SocialForever receives them.
- Added a deliberate combat-time Invite action for overlay entries using `C_PartyInfo.InviteUnit` with the already-normalized player name. The existing protected target rows remain frozen underneath and are fully repainted after combat.
- Newly remapped combat entries intentionally do not expose the stale secure row target action; click-to-target is re-armed only after combat ends. Live Forever verification of the new combat overlay/invite path is still required.
- Fixed familiar-player recognition so the "I've seen this ... before" thought cannot appear before the player exists in the current Nearby list.
- Target recognition now promotes the target through the normal Nearby detection path before printing the thought.
- Delayed recognition re-checks that the player is still Nearby before firing, preventing stale messages after somebody has already disappeared.
- Recognition that becomes ready during combat is deferred until combat ends and the secure Nearby rows can repaint.
- Added current-sighting provenance to Nearby tooltips. The tooltip now shows one concise reason rather than every observed origin; the underlying current-sighting record may retain multiple origins.
- Detection reasons are ephemeral current-sighting evidence, not permanent reputation/history data. Historical locations remain separate under **Seen before in**.
- Improved nearby crafting detection: SocialForever now accepts real craft announcements from both `CHAT_MSG_TRADESKILLS` and craft-shaped `CHAT_MSG_SYSTEM` messages.
- Craft messages use Blizzard's localized `TRADESKILL_LOG_THIRDPERSON` / created-item templates when available, with the event sender/GUID preferred over text parsing for player identity.
- Stopped treating `CHAT_MSG_SKILL` as nearby crafting evidence; it primarily reports the local player's own skill gains.
- Removed the three-second Combat Log chat-frame parser. Forever intentionally protects combat-log text from addon parsing, so nearby combat discovery now relies on exposed unit tokens/interactions and the built-in Damage Meter path instead.
- Skinning is documented as gathering rather than crafting; no dedicated nearby-player Skinning event is currently verified.

## 0.4.8-beta — 2026-11-05

- Fixed the live Forever combat-lockdown error `[ADDON_ACTION_BLOCKED] Button:SetHeight()` caused when `RefreshList()` tried to resize secure player rows during combat.
- Secure row geometry, visibility and list animations are now deferred while combat lockdown is active. Detection and memory state continue updating underneath, and one forced repaint runs on `PLAYER_REGEN_ENABLED`.
- Fixed a second live protected-action error from `CheckInteractDistance`. SocialForever now skips that API entirely during combat instead of relying on `pcall`, allowing existing distance/visibility fallbacks to handle detection without invoking the restricted function.
- Added automated combat-lockdown regression coverage and static checks for both the deferred secure-row repaint and the protected interaction guard.
- Automated verification is green. Babuni then retested the corrected combat paths in the live Forever client and the two previously observed BugGrabber protected-action errors did not recur. This is a focused regression retest, not a claim that every addon feature has been fully reverified in-game.
- Reconciled post-0.4.7 release documentation without moving or rewriting the already-published `v0.4.7-beta` tag.

## 0.4.7-beta — 2026-11-04

- Added a GitHub Actions pre-release verification suite covering Lua syntax, SavedVariables migration, the Forever race/class icon matrix, familiarity and recognition, memory reset, raid presence and API-call counts, sorting, Nearby/Zone separation, same-mob prompt safety, sharing privacy, name normalization, static cleanup, TOC integrity, and package re-extraction checks.
- Automated checks are explicitly local/mock verification; they do not count as live Forever client testing. This beta is being released before final launch-day in-game verification; any client-specific issues found after servers open will be fixed in a follow-up version.
- Removed **Auto-invite friends** and all dead friend auto-invite code. Friend detection remains available for future visual highlighting.
- Removed **same-mob Auto-invite** and programmatic invite paths. Same-mob grouping can only offer the user a secure, clickable Invite action.
- Corrected race/class icons to the official Forever matrix and removed later-client-only race/class combinations and Death Knight mappings.
- Unknown combinations now fall back to the known class icon before the generic race portrait.
- Raid membership alone no longer keeps a player Nearby indefinitely, and presence validation reuses cached group tokens instead of rescanning the full raid.
- Added a lightweight periodic sort refresh so distance/recency changes can reorder an unchanged list.
- Added the repository MIT license to match the existing CurseForge license declaration.


## 0.4.6-beta — 2026-10-22

- Player tooltips no longer show **General: no mark yet**, **Your mark: none yet**, or **Flags: none**. General and Flags lines appear only when there is something to say.
- Tooltip place lines match **Been nearby:** style: **Last seen: Place** and **Seen before: Place, Place** (no “minutes ago” wording).

## 0.4.5-beta — 2026-10-20

- Familiar recognition: when a blue or purple familiar enters Nearby (not Zone alone) or you target them, chat quietly thinks **I've seen this Human Paladin before.** (race/class when known). Per-player 20-minute cooldown survives reload/logout. Nearby thoughts wait a random 2–5 seconds so the list can settle first.
- Settings → Memory: reset one remembered player, or reset all remembered players (window and grouping settings stay).
- Nearby familiarity is place-based again: dropping off the list and coming back in the **same** subzone or city does not add another “Been nearby” charge (survives reload/logout). A charge only happens when you meet them again in a **different** place.

## 0.4.4-beta — 2026-10-14

- Flags are personal only. Nearby Social Forever users still exchange Green / Yellow / Red marks, but not flags. Your flags stay as private reminders on your character.
- Fixed a Nearby glitch where the tab could show **(1)** while the list stayed empty: the empty list area no longer keeps the list “frozen,” and new people (such as someone who just buffed or healed you) still appear even if your mouse is on a row.
- Buff/heal detection still works when the combat aura payload is missing or sealed, by reading your helpful auras directly.

## 0.4.3-beta — 2026-10-13

- When someone declines your party invite, Social Forever remembers it. The tooltip shows **Denied invite** in red with the count (1 time, 2 times, …), next to how often you have grouped together.

## 0.4.2-beta — 2026-10-10

- Same-mob grouping no longer pretends an invite was sent when Forever blocks programmatic invites. It opens the clickable Invite prompt right away instead of waiting on a dead cooldown.
- Damage-meter harvest retries when combat or an empty meter would have skipped a fight, so same-mob prompts show up sooner after you leave combat.
- The Invite button only shows **Invited** when the secure `/invite` is actually armed for that person.
- Invite tooltip notes that people in combat see the popup only after they leave combat.

## 0.4.1 — 2026-10-08

- Nearby and zone people are on separate tabs. The nearby tab uses your subzone name; the zone tab uses the zone name (and can show 100+).
- After you change subzone, names stay on Nearby for at least 15 seconds so the list does not jump as much.
- Optional same-mob grouping: ask before inviting, or auto-invite, when someone nearby was damaging the same mob you were. Both settings default off.
- Mouseovers and other sightings can show on the list during combat; brand-new rows stay click-safe until combat ends.
- Memory is Nearby-only: “Been nearby” counts real Nearby encounters, and “Seen before in …” only updates when they have been Nearby. The old same-zone times line is gone.

## 0.3.2 — 2026-10-07

- Marks, clear mark, and Kill on sight update that player's color and letter on the list right away, even while your mouse is over it.
- After you leave the list, sorting and normal updates continue as usual.

## 0.3.1 — 2026-10-07

- Your current target stays at the top of Nearby while you have them targeted.
- The Nearby list no longer jumps around while your mouse is over it — invites and clicks stay on the same person until you move away.
- Player tooltips show level, race, and class.

## 0.3.0 — 2026-10-07

- Same player-facing behavior. The addon code is now split into several Lua files so it is easier to maintain.

## 0.2.32 — 2026-10-07

- Nearby drops people sooner when they are clearly gone or stop showing up for a short while. The 3-minute timer is still the last resort.

## 0.2.31 — 2026-10-07

- Same detection and list behavior, with less repeated background work while you play.

## 0.2.30 — 2026-10-07

- **In this zone** from the General roster should work without people talking. The roster reader was still using the wrong channel id and GUID fields.

## 0.2.29 — 2026-10-06

- **In this zone** now fills from the General channel roster again, without waiting for someone to speak.

## 0.2.28 — 2026-10-06

- Players of the other faction show in a dusty war-red on the list, different from a Red mark.

## 0.2.27 — 2026-10-06

- Offline group members and old damage-meter names no longer keep showing up on Nearby.

## 0.2.26 — 2026-10-06

- Each nearby name now shows a race-and-class icon between the name and the level.
- The level uses that player's class color. Skyborne have their own icon set.

## 0.2.25 — 2026-10-06

- More ways to notice people nearby: friendly nameplates you already enabled, players who buff you, resurrections, and other combat participants after a fight ends.
- The General channel roster and yell now feed **In this zone** without counting as a real encounter.
- Raid members in range and a few extra unit tokens are scanned the same way as party targets.

## 0.2.24 — 2026-10-06

- Your own character no longer appears in the nearby list.

## 0.2.23 — 2026-10-05

- Two-word names no longer trigger “No player named … is currently playing” when Social Forever tries to say hello. Those names are not whispered.

## 0.2.22 — 2026-10-05

- Fixed a Lua error that could fire in a dungeon while in a group, when the client sealed a unit name.

## 0.2.21 — 2026-10-05

- First CurseForge beta.
- The close **x** sits in the top-left corner, away from the gear button.
- Hovering the **x** shows that `/sf` or `/socialforever` brings the window back.

## Documentation-only audit — 2026-10-27 (#32)

- Added missing visual-design, content/provenance and AI-collaboration guides; expanded overview, architecture, roadmap, development-history and decision navigation.
- Preserved the original 0.4.6-beta history and Lua implementation. No addon behavior or version metadata was changed, and no client/network tests were run during the audit.

# SocialForever — design evidence

**Human creative:** Babuni

## Approach found in source

It seeks familiarity rather than a constant automated nameplate layer; it works with nameplates switched off, preserves account-wide encounter history and offers subjective personal marks. Shared marks require caution in social presentation.

No original acceptance date or rejected alternative is inferred solely from existing code.

## Open validation

Review detection-source false positives, large-local-population behavior, invite prompts, group review, sharing privacy and SavedVariables migrations in-game.

## Documented decisions and corrections — audit #32

- **Local familiarity rather than nameplates:** Babuni's direction is an unobtrusive list while nameplates are off, supporting recognition and deliberate invitations. This is the human design aim; automated recognition/detection details evolved through implementation.
- **0.3.0 modularization:** [DEVELOPMENT](../DEVELOPMENT.md) records moving from one large Lua unit into seven ordered modules; saved-data compatibility was intended to remain intact.
- **0.3.1 interaction stability:** Hover freezes list movement and the target pins to the first Nearby row; deferred updates appear after the user exits the interactive area.
- **0.4.1 provenance distinction:** General roster supplies **Zone** entries; personal familiarity derives from **Nearby** sightings. Same-mob invite prompts are optional and default off.
- **0.4.2 protected invite correction:** A `pcall` success is not proof of an invite. The interface must use the secure path before recording success.
- **0.4.4 privacy decision:** Marks can be shared; subjective personal flags stay private. The wire field remains empty for compatibility.
- **0.4.5 recognition:** Blue/purple familiar players may trigger a quiet race/class thought on a Nearby entrance or when targeted; one per-person 20-minute cooldown persists, with a 2–5-second delayed Nearby message.

These decisions are evidenced by recorded development changes. Where an original conversation or explicit acceptance is not preserved, do not fabricate one or infer that every implementation choice came from Babuni.


## Pre-release decisions — 2026-11-04

- **Invites remain deliberate:** friend auto-invite and same-mob auto-invite are removed. An invitation is only sent from a player's secure click.
- **Future social highlighting:** better friend highlighting and highlighting players who fought the same mob are future ideas, not implemented features.
- **Forever-only race/class data:** icon overrides follow Blizzard's official Forever combinations; later-client-only combinations are not supported.
- **Raid membership is not proximity:** being in the same raid cannot by itself keep a character in Nearby.

- **0.4.7-beta release timing:** On 2026-11-04 Babuni approved preparing and publishing the beta before final live-client testing because the Forever servers were not yet playable. Automated/local verification must remain described as such; any launch-day client defects are follow-up fixes, not evidence that the beta was pre-release in-game verified.

## Live combat correction — 2026-11-05

- **Combat range fallback:** `CheckInteractDistance` is not called by SocialForever while combat lockdown is active. Live Forever produced `ADDON_ACTION_BLOCKED` despite the call being wrapped in `pcall`; the addon therefore treats the API as unavailable in combat for this path and falls back to other evidence instead of probing it.

## Hotfix release decision — 2026-11-05

- **0.4.8-beta hotfix timing:** Live Forever testing exposed two protected-action failures in 0.4.7-beta: secure list-row layout changes during combat and a combat-time `CheckInteractDistance` call. Babuni directed immediate release preparation once both fixes and their automated regression checks passed. Final live retesting of the corrected paths is still pending and must not be described as completed.

## Local workflow and UI direction — 2026-11-10

- **Main only:** For this small addon, Babuni directed development on `main` without feature branches. Remote leftover CI/feature/release branches and draft PRs were closed/deleted. Push and version tags happen only when Babuni explicitly asks after local Forever testing.
- **Settings slimmed:** Settings keep **Name size** and **Background**. Same-mob grouping prompts and Memory reset menu entries were removed from Settings by Babuni's direction. Same-mob ask remains forced off; shared combat/activity detection stays for other features. A later request added **Show buff caster**.
- **Header layout:** Top row is close, settings, region (zone) tab, Nearby tab.
- **Tooltip experiment rejected:** A centered, spaced, underlined tooltip layout was tried in live play and rejected because it felt too heavy and made some tooltips look wrong. Compact default tooltip returned; guild in green `<Guild>` under level/race/class remains.
- **Marks vs familiarity color:** Green / Yellow / Red color only the left-side mark letter. Names keep familiarity (or other-faction) tint so “how often I’ve seen them” stays visible. Kill on Sight may still tint the name.
- **Never show realm names:** Babuni directed that realm must never appear in the list or tooltip. Forever buff/GUID paths return internal realm tokens that must not be appended to keys; display and invite names stay character-name only.
- **Every player has two names:** Babuni stated that Forever is a two-name game and a one-word name must never appear in the list. Realm tokens are stripped, but a second name delivered in the API realm slot is kept. An earlier AI change that dropped every realm-slot value was a regression and was reversed.
- **No invite for the other faction:** Babuni directed that other-faction players in the list must not show an Invite button. They stay listed with their muted red name; only the invite action is removed.
- **Never list yourself:** The local player must never appear on Nearby/Zone and must never gain familiarity charges. Identity resolution rejects the player unit and player GUID; leftover self rows are purged.
- **Stricter Nearby eviction:** Unknown-range tokens do not keep people forever. An AI-proposed instant drop on nameplate loss was tried and rejected by Babuni as too quick. Babuni chose a middle ground: nameplate loss starts a short grace (15s trackable, 20s interaction) and people linger briefly before leaving. The old 180s lifetimes, 18/25s grace, and unknown-range lingering were not restored. Buff casters later moved to that same nearby lifetime instead of a shorter buff TTL that aura updates kept restarting.
- **Hot-path performance:** After a CPU peg from scrubbing all SavedVariables players inside Publish/ValidatePresence, Babuni required that account-wide cleanup never run on Scan/Publish/presence ticks. Player identity must be cached. `AGENTS.md` now states this as a mandatory rule; docs must be updated with every implementation step, not deferred until push.
- **Buffs use the normal nearby lifetime:** Babuni asked that players listed because they buffed them leave on the same shelf life as other encounters, instead of staying for the whole buff. Repeat aura updates no longer restart that timer.
- **Buff caster on the tooltip:** Babuni asked whether the buff tooltip can name the player who cast it, as a setting. It can when Forever exposes the caster. **Show buff caster** is on by default and can be turned off in the gear menu. If the caster is sealed, the line is omitted.
- **A disconnect is not a goodbye:** Babuni asked that the rating window stay closed when a party member goes offline but remains in the group. The question waits until that person actually leaves. Offline members still leave the Nearby list.
- **A full group is not a goodbye:** Babuni saw the rating window open for Unknown every time the last person joined, including from the group finder. Filling a party is not someone leaving. Unresolved client names are ignored, and the rating window waits until every connected party slot has a real name. Asking when a real person leaves, or when the party ends, stays.
- **One list in combat:** Babuni directed that entering combat must not swap the visible list for a second combat list. The same rows may update. Invite should keep working from that list during a fight when the client allows it. A later live error showed `TargetUnit()` is forbidden for addon code even outside combat, so name clicks use a secure `/target` button that the client hides during a fight. Clicking a name in combat prints a short chat line. Babuni then found those clicks sometimes stayed dead after reload and after the fight ended; the target button must be shown again as soon as combat lockdown is over. Hiding Invite for the whole fight was the fallback and was not needed for Forever's party invite API. The earlier combat overlay is the rejected approach.

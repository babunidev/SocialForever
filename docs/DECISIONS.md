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


## Party review — 2026-11-08

- **Membership is not connection state:** a player who disconnects but remains on the party roster is still a group member. Their online Nearby presence may expire, but the group-review snapshot must retain them.
- **Review only confirmed members:** pending or declined invitations do not count as group members. Party unit tokens must be confirmed through Forever's `UnitInParty` API before entering group history or review snapshots.
- **Departure means roster removal:** the review prompt is triggered when a previously confirmed member is removed from the party roster. This covers ordinary voluntary leave and kick behavior. `UNIT_CONNECTION` only updates online state and never counts as a departure.
- `GROUP_ROSTER_UPDATE` has no removal-reason payload in Forever 1.60.1. If the server automatically removes a disconnected member after a timeout, the addon cannot distinguish that policy from a kick using the roster event alone; a separate reason-bearing signal would be needed.
- Live testing is still required to confirm these event transitions in the running Forever client.
- **Declined invitations are not departures:** the system-message decline handler updates the invite's declined state and personal counter only. It does not create a group rating; only a confirmed member's roster removal does.

# SocialForever — design evidence

**Author:** Babuni.dev

## Approach found in source

It seeks familiarity rather than a constant automated nameplate layer; it works with nameplates switched off, preserves account-wide encounter history and offers subjective personal marks. Shared marks require caution in social presentation.

No original acceptance date or rejected alternative is inferred solely from existing code.

## Open validation

Review detection-source false positives, large-local-population behavior, invite prompts, group review, sharing privacy and SavedVariables migrations in-game.

## Documented decisions and corrections — audit #32

- **Local familiarity rather than nameplates:** Babuni.dev's direction is an unobtrusive list while nameplates are off, supporting recognition and deliberate invitations. This is the human design aim; automated recognition/detection details evolved through implementation.
- **0.3.0 modularization:** [DEVELOPMENT](../DEVELOPMENT.md) records moving from one large Lua unit into seven ordered modules; saved-data compatibility was intended to remain intact.
- **0.3.1 interaction stability:** Hover freezes list movement and the target pins to the first Nearby row; deferred updates appear after the user exits the interactive area.
- **0.4.1 provenance distinction:** General roster supplies **Zone** entries; personal familiarity derives from **Nearby** sightings. Same-mob invite prompts are optional and default off.
- **0.4.2 protected invite correction:** A `pcall` success is not proof of an invite. The interface must use the secure path before recording success.
- **0.4.4 privacy decision:** Marks can be shared; subjective personal flags stay private. The wire field remains empty for compatibility.
- **0.4.5 recognition:** Blue/purple familiar players may trigger a quiet race/class thought on a Nearby entrance or when targeted; one per-person 20-minute cooldown persists, with a 2–5-second delayed Nearby message.

These decisions are evidenced by recorded development changes. Where an original conversation or explicit acceptance is not preserved, do not fabricate one or infer that every implementation choice came from Babuni.dev.

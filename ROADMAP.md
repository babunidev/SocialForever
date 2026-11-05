# SocialForever — roadmap

**Human creative:** Babuni

## Existing state

Code, metadata, README and release history are present. The 2026-10-27 documentation pass did not execute the game or tests; the later 0.4.7-beta release candidate passed automated/mock verification, while live Forever verification remains pending.

## Verification backlog (proposed)

- [x] Keep familiar-player recognition synchronized with the actual Nearby list.
- [ ] Live-test recognition from a deliberate target, delayed Nearby recognition, disappearance before the timer fires, and recognition queued across combat lockdown.
- [x] Add current-sighting provenance to Nearby tooltip entries without persisting it as reputation data.
- [ ] Live-test tooltip provenance for target, mouseover, crafting and post-combat Damage Meter detection.
- [x] Audit nearby craft/combat detection after live observation of an undetected fighter/skinner.
- [x] Add `CHAT_MSG_SYSTEM` craft detection and localized craft-template parsing; stop using `CHAT_MSG_SKILL` as nearby craft evidence.
- [x] Remove protected Combat Log chat polling and keep `C_DamageMeter` as the supported post-combat source.
- [ ] Live-test another player's ordinary crafting announcement and record which Forever event path fires.
- [ ] Live-test another player's Skinning with Event Trace/debug observation; do not treat Skinning as directly detectable until an identity-bearing event is observed.
- [x] Diagnose the live Forever `Button:SetHeight()` protected-frame failure during combat and implement deferred secure-row painting.
- [x] Diagnose the live Forever `CheckInteractDistance` protected-call failure and prevent all combat-time calls through `Util.Interact`.
- [x] Re-test the two reported combat failure paths in the live Forever client; the previous protected-action errors did not recur.
- [ ] Continue broader live verification of combat list behavior, new sightings, post-combat repaint details, Nearby/Zone separation, invites, sharing and persistence.
- [x] Prepare 0.4.8-beta as the urgent combat hotfix candidate after automated verification passed.
- [ ] Publish and verify 0.4.8-beta on GitHub and CurseForge.

## Future ideas (not implemented)

- Better visual highlighting for existing friends.
- Highlight players who fought the same mob, without inviting them automatically.


Review detection-source false positives, large-local-population behavior, invite prompts, group review, sharing privacy and SavedVariables migrations in-game.

No unapproved features were added as milestones.

## Evidence-based acceptance ledger — 2026-10-27

- [x] Preserve the original DEVELOPMENT and CHANGELOG records intact.
- [x] Add design, content/provenance and human–AI collaboration documentation.
- [x] Reconcile current 0.4.6-beta behavior with the release history and seven-module architecture.
- [ ] Verify Nearby versus General Zone separation in-game, including aura, say, shared-mob and token-expiry evidence.
- [ ] Exercise target pinning, freeze/unfreeze, ordering and performance during crowded/combat situations.
- [ ] Test secure Invite behavior, opt-in same-mob prompts and invitation decline detection on the Forever client.
- [ ] Verify SavedVariables persistence for recognition cooldown, place history, user flags and account-wide reset without data loss.
- [ ] Confirm that sharing sends marks but never flags or private judgments, including compatibility with older addon clients.
- [ ] Review accessibility and privacy-safe screenshots before portfolio publication.

These are verification tasks, not approval for new gameplay features. No in-game tests were performed in this documentation pass.


## Release preparation

- [x] Run deterministic pre-release syntax, mock, privacy, static and package-integrity checks through GitHub Actions; keep them explicitly separate from live Forever testing.
- [ ] Update the live CurseForge project description: marks are shared, flags stay private, and no friend or same-mob auto-invite is offered. Corrected copy is prepared in `docs/CURSEFORGE_DESCRIPTION.md`, but the live description has not been confirmed updated.
- [x] Prepare 0.4.7-beta from the green automated verification suite for launch-day publication.
- [x] Publish annotated tag `v0.4.7-beta` and the matching GitHub prerelease from release commit `4c71618fa453619cfae6144d6fe8f576b995c60b`.
- [x] Confirm the CurseForge integration accepted the tag and created a Beta file for Forever 1.60.1; it was observed in **Processing** state.
- [ ] Confirm the CurseForge file reaches **Approved** and verify the final downloadable package contents.
- [ ] Complete live Forever verification after the client is available; for 0.4.7-beta this is explicitly deferred until after publication and does not retroactively become pre-release verification.

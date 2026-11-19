# SocialForever — roadmap

**Human creative:** Babuni

## Existing state

Code, metadata, README and release history are present. The 2026-10-27 documentation pass did not execute the game or tests; the later 0.4.7-beta release candidate passed automated/mock verification, while live Forever verification remains pending.

## Verification backlog (proposed)

- [x] Restore immediate visual Nearby additions during combat without mutating protected target rows.
- [x] Add a deliberate combat-time Invite path for newly detected overlay entries.
- [ ] Live-test mouseover discovery while already in combat: entry should appear immediately with **Nearby because: Hovered / mouseover**.
- [ ] Live-test inviting that newly detected player before combat ends and confirm no `ADDON_ACTION_BLOCKED` event occurs.
- [ ] Live-test that entering combat keeps the same Nearby rows, a new mouseover appears on that list, and Invite sends during the fight with no `ADDON_ACTION_BLOCKED`.
- [ ] Live-test that clicking a name during combat does not target or error, and that the same click targets again after the fight.
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

## Unreleased local work (2026-11-10)

- [x] Slim Settings to Name size and Background; remove same-mob and Memory reset from Settings UI.
- [x] Reorder main header: close, settings, region, Nearby.
- [x] Show guild on player tooltips when known from a unit; keep compact tooltip after rejecting the centered experiment.
- [x] Color Green/Yellow/Red marks on the left letter only; keep familiarity color on the name.
- [x] Restore AGENTS.md and docs into the Forever AddOns working tree; document main-only local-first workflow.
- [ ] Live-check guild on tooltip after mouseover/target for guilded and unguilded players.
- [ ] Decide whether Memory reset stays available through another path or remains removed.
- [x] Keep one Nearby/Zone list in combat: same rows, Invite still on that list, no combat overlay.
- [x] Give buff casters the same nearby lifetime as other encounters, and stop aura updates from restarting that timer.
- [x] Add a settings toggle that writes the known buff caster on the player's own buff tooltip.
- [ ] Live-test the one list in Forever: enter combat, confirm the rows do not swap, a new mouseover appears, Invite sends, and a name click does not error.
- [ ] Live-test that a buff caster leaves on the normal nearby timer, and that the buff tooltip shows From: their name when the caster is known. Turn the line off in Settings and confirm it stays off.
- [x] Tag and publish `v0.4.10-beta` after Babuni asked on 2026-11-11. Automated checks passed. Live Forever checks below stay open.
- [x] Tag and publish `v0.4.11-beta` after Babuni asked on 2026-11-13. Automated checks passed. The rating-window live checks below stay open.
- [ ] Push/tag later versions only when Babuni explicitly asks.
- [ ] Live-test that filling the last party slot, including from the group finder, does not open **How was this player?** for Unknown, and that someone actually leaving still opens it.
- [ ] Live-test that a party member going offline does not open the rating window, and that it opens when they actually leave the group.

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
- [ ] Test secure Invite behavior and invitation decline detection on the Forever client.
- [ ] Verify SavedVariables persistence for recognition cooldown, place history and user flags without data loss.
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

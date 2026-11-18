# SocialForever — Human–AI Collaboration

Follow [the documentation standard](DOCUMENTATION.md) for first-person author voice throughout project documentation, factual changelogs, and naming the AI tool and verified model for each contribution.

## Recognizing people in the world

With nameplates off in World of Warcraft: Forever, I wanted to notice nearby people, target or invite them quickly and recognize faces I had seen before. A quiet note about a familiar character’s race and class was my way of encouraging attention to the people around me.

## Implementations and corrections in the record

The [development notes](../DEVELOPMENT.md) and [changelog](../CHANGELOG.md) document transitions from a large Lua file to modular responsibilities; stability work to freeze the list during interaction; a distinction between Nearby and General Zone listings; opt-in shared-mob invitations; private flags rather than propagated judgments; and a persistent 20-minute cooldown for familiar recognition. AI assistance may be credited for code and documentation only where evidence supports the particular contribution.

## Audit #32 — 27 October 2026

**User direction:** Continue repository-by-repository documentation consolidation; retain original authorship and preserve historical decisions. **AI contribution:** Read current README, TOC, several Lua modules, release notes and development log; create navigational guides for visual design, content privacy, technical architecture and the history of design decisions. **Iteration:** Preserve the documented shifts in invitation logic and private flag sharing rather than presenting the first approach as final. **Verification:** No client, network, party-invite, persisted-data migration or CurseForge release test was run. This pass changes documentation only.

Document proposals as proposals, implemented code as source-observed and release-test claims as historically reported. Do not reproduce private user data or mistake subjective community opinions for established facts.

## Release preparation and publication — 4 November 2026

**Human direction:** For this release, I approved removing unattended invite paths, keeping invitations deliberate, preparing 0.4.7-beta before final live-client testing, and publishing that exact beta once automated verification was green. **AI contribution:** repository audit, release-diff review, GitHub Actions test coverage, package-integrity checks, release-document preparation and GitHub repository updates. **Human-operated publication:** From my terminal, I created and pushed the annotated `v0.4.7-beta` tag and created the matching GitHub prerelease from the terminal. **Verification:** the exact release commit passed automated/local checks; GitHub publication is confirmed; CurseForge accepted the tag-triggered Beta for Forever 1.60.1 and was observed in Processing state; live Forever testing and final CurseForge approval remain pending.

## Combat hotfix preparation — 5 November 2026

**Human direction:** To explain the direction, I supplied both live BugGrabber reports and directed an immediate tagged hotfix once the combat restrictions were diagnosed. **AI contribution:** traced the secure-row and `CheckInteractDistance` failures, implemented combat-safe guards, extended regression/static checks, synchronized release metadata and documentation, and prepared 0.4.8-beta. **Verification:** automated checks cover both corrected paths and package integrity. After the fix, I performed a focused live Forever combat retest in which the two previously observed protected-action errors did not recur. Broader addon verification remains separate.

## 18 November 2026 — Collaboration record review

At my request, Codex (GPT-6) revised this record for first-person voice and checked the attribution against the available repository documentation. Where an earlier AI tool or model is missing from the record, its identity remains unconfirmed.

# SocialForever — Human–AI Collaboration

**Human creative and creative direction:** Babuni

## Creative direction

Babuni wanted a practical social helper for World of Warcraft: Forever while playing with nameplates switched off: discover nearby people, quickly target or invite them and recognize familiar faces. A quiet message about having seen a character of a given race and class before was intended to encourage paying attention to the world and its inhabitants. That social intention is Babuni's contribution, not an AI invention.

## Implementations and corrections in the record

The [development notes](../DEVELOPMENT.md) and [changelog](../CHANGELOG.md) document transitions from a large Lua file to modular responsibilities; stability work to freeze the list during interaction; a distinction between Nearby and General Zone listings; opt-in shared-mob invitations; private flags rather than propagated judgments; and a persistent 20-minute cooldown for familiar recognition. AI assistance may be credited for code and documentation only where evidence supports the particular contribution.

## Audit #32 — 27 October 2026

**User direction:** Continue repository-by-repository documentation consolidation; retain original authorship and preserve historical decisions. **AI contribution:** Read current README, TOC, several Lua modules, release notes and development log; create navigational guides for visual design, content privacy, technical architecture and the history of design decisions. **Iteration:** Preserve the documented shifts in invitation logic and private flag sharing rather than presenting the first approach as final. **Verification:** No client, network, party-invite, persisted-data migration or CurseForge release test was run. This pass changes documentation only.

Document proposals as proposals, implemented code as source-observed and release-test claims as historically reported. Do not reproduce private user data or mistake subjective community opinions for established facts.

## Release preparation and publication — 4 November 2026

**Human direction:** Babuni approved removing unattended invite paths, keeping invitations deliberate, preparing 0.4.7-beta before final live-client testing, and publishing that exact beta once automated verification was green. **AI contribution:** repository audit, release-diff review, GitHub Actions test coverage, package-integrity checks, release-document preparation and GitHub repository updates. **Human-operated publication:** Babuni created and pushed the annotated `v0.4.7-beta` tag and created the matching GitHub prerelease from the terminal. **Verification:** the exact release commit passed automated/local checks; GitHub publication is confirmed; CurseForge accepted the tag-triggered Beta for Forever 1.60.1 and was observed in Processing state; live Forever testing and final CurseForge approval remain pending.

## Combat hotfix preparation — 5 November 2026

**Human direction:** Babuni supplied both live BugGrabber reports and directed an immediate tagged hotfix once the combat restrictions were diagnosed. **AI contribution:** traced the secure-row and `CheckInteractDistance` failures, implemented combat-safe guards, extended regression/static checks, synchronized release metadata and documentation, and prepared 0.4.8-beta. **Verification:** automated checks cover both corrected paths and package integrity. Babuni then performed a focused live Forever combat retest in which the two previously observed protected-action errors did not recur. Broader addon verification remains separate.

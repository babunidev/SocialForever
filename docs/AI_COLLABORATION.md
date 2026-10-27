# SocialForever — Human–AI Collaboration

**Author and creative direction:** Babuni.dev

## Creative direction

Babuni.dev wanted a practical social helper for World of Warcraft: Forever while playing with nameplates switched off: discover nearby people, quickly target or invite them and recognize familiar faces. A quiet message about having seen a character of a given race and class before was intended to encourage paying attention to the world and its inhabitants. That social intention is Babuni.dev's contribution, not an AI invention.

## Implementations and corrections in the record

The [development notes](../DEVELOPMENT.md) and [changelog](../CHANGELOG.md) document transitions from a large Lua file to modular responsibilities; stability work to freeze the list during interaction; a distinction between Nearby and General Zone listings; opt-in shared-mob invitations; private flags rather than propagated judgments; and a persistent 20-minute cooldown for familiar recognition. AI assistance may be credited for code and documentation only where evidence supports the particular contribution.

## Audit #32 — 27 October 2026

**User direction:** Continue repository-by-repository documentation consolidation; retain original authorship and preserve historical decisions. **AI contribution:** Read current README, TOC, several Lua modules, release notes and development log; create navigational guides for visual design, content privacy, technical architecture and the history of design decisions. **Iteration:** Preserve the documented shifts in invitation logic and private flag sharing rather than presenting the first approach as final. **Verification:** No client, network, party-invite, persisted-data migration or CurseForge release test was run. This pass changes documentation only.

Document proposals as proposals, implemented code as source-observed and release-test claims as historically reported. Do not reproduce private user data or mistake subjective community opinions for established facts.

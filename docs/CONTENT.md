# SocialForever — Content Model and Provenance

**Author:** Babuni.dev

## Personal records

`SocialForeverDB` is an account-wide SavedVariables store. The README and source modules describe player identity, class/race/level when known, remembered locations, proximity history, personal marks and flags, group ratings, invitation history, and recognition cooldown timestamps. Saved information should be treated as an individual player's subjective memory, not objective facts about other players.

## Detection and distinction

Source classes include live target/mouseover/group/nameplate units, observed helpful aura casters, chat/contact events, and combat-related shared-mob evidence. General roster entries are **Zone** candidates, not confirmed people physically nearby. Detection evidence, memory persistence and current UI visibility are separate states.

## Shared versus private

The October 14 v0.4.4-beta change made **flags private**; `Sharing.Encode` writes an empty compatibility field and `StoreRemote` ignores incoming flag text. Subjective Green/Yellow/Red marks may be exchanged with compatible nearby addon users. Decline counts and KOS remain personal. A general mark is a summary of received opinions, not a verified reputation score.

## Release and development evidence

The [CHANGELOG](../CHANGELOG.md) records player-facing releases; [DEVELOPMENT](../DEVELOPMENT.md) describes code decisions and corrections. The current metadata declares interface **16001**, addon version **0.4.6-beta**, and `SocialForeverDB`. Keep these records discoverable without inventing a release/test chronology.

## Portfolio publication

Use illustrative fictionalized or author-approved player names in screenshots and examples. Never expose real stored social judgments, identifiable player encounter histories, private flags, private chat or account data without permission. The portfolio may explain the design mechanics, constraints, decisions, and tested behavior using code and sanitized captures.

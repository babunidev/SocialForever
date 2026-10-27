# SocialForever — Interaction and Visual Design

**Author:** Babuni.dev  
**Scope:** Source-grounded guide to the 0.4.6-beta interface; no fresh in-game tests.

## Purpose

SocialForever is designed for a player who keeps nameplates off but wants to notice people encountered during ordinary play. The movable window makes nearby people easier to target and invite without a conventional permanent nameplate overlay. Its wider ambition is social familiarity: repeat encounters can turn strangers into recognizable names.

## List behavior

The [development log](../DEVELOPMENT.md) records the 0.4.1 separation into **Nearby** and **Zone** tabs. Zone is informed by the General roster but does not count as physical proximity or personal familiarity. Nearby focuses on sightings supported by local evidence. The current target is pinned atop Nearby (0.3.1). Hovering over the interactive list freezes the displayed order to protect clicks; underlying detection continues and the list refreshes on exit.

## Personal memory and signals

A player's name and tooltip can reflect individual Green/Yellow/Red marks, general marks, remembered places, repeat-encounter bands, private flags, declined invites and Kill on Sight. The 0.4.6-beta revision deliberately removes empty tooltip lines rather than displaying meaningless categories. The 0.4.5-beta familiar-thought message is a quiet, muted chat observation, not a sound or public emote. It triggers from genuine Nearby appearance or targeting, not merely being listed in Zone.

## Interaction safety

The 0.4.2-beta entry documents why invite confirmation must reflect an actual secure send path rather than a successful API call wrapper. Same-mob ask/auto behavior is opt-in; when automation cannot send an invite reliably, the secure invitation interface takes precedence. Interaction freezing should protect intentional selection while not hiding newly detected players indefinitely.

## Open accessibility and runtime checks

Keyboard targeting, gamepad interaction, small-screen layout, combat lockdown behavior, list accuracy, UI performance and accessible tooltip content need independent client testing. Existing release notes are historical implementation reports, not new acceptance results.

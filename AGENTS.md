# SocialForever — development rules

**Human creative:** Babuni

Preserve source-supported mechanics and user intention. Document historical user decisions separately from AI suggestions. Existing code is not proof of in-game verification. Maintain README, CHANGELOG, concept, roadmap and DEVLOG with later changes, and retain evidence of rejected alternatives.

## Local development workflow

Read this file and [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md) at the start of every development turn before changing Lua or docs. Keep documentation in the same working tree as the Lua (including the Forever AddOns install when that is the active workspace), not only on GitHub.

Develop on **`main` only** for this small project; do not create feature branches unless Babuni asks. Edit and test locally in the Forever client first. Commit, push, and create version tags only when Babuni explicitly says to. Until 1.0.0, release tags stay beta (for example `v0.4.10-beta`).

## Performance and hot paths (mandatory)

SocialForever runs Scan/Publish on short timers inside a live game client. Never add work that scales with full SavedVariables or full player history onto those paths.

- **Forbidden on Scan / Publish / ValidatePresence / OnUpdate / row paint:** walking `SF.db.players`, `SF.db.remote`, or other account-wide tables; full-memory scrubbing; repeated `UnitName("player")` / `UnitGUID("player")` without a cache; creating new tickers without removing old ones.
- **Allowed on those paths:** O(current Nearby/Zone sightings) work, cheap cached identity checks (`Util.IsMe` via cached `MyKey`), dropping a single key.
- **One-shot login/migration only:** account-wide cleanup such as `Util.PurgeSelfRecords`.
- Before finishing a change that touches Detection, Events timers, Publish, ValidatePresence, or identity helpers, ask: “Could this run dozens of times per second or over the whole memory DB?” If yes, redesign it.
- Incident reminder (2026-11-10): calling `PurgeSelfRecords` from Publish/ValidatePresence pegged CPU because it scrubbed all remembered players on every tick. That class of mistake must not recur.

## Document every implementation step

When code behavior changes, update the matching docs **in the same working pass**, before considering the task done:

| Change type | Update |
| --- | --- |
| Player-visible behavior | `CHANGELOG.md` Unreleased, `README.md` if it describes current UX |
| Why / creative decision / rejected approach | `docs/DECISIONS.md`, short `docs/DEVLOG.md` entry |
| Implementation detail / timers / detection | `docs/DEVELOPMENT.md` (newest first) |
| Planned follow-up | `docs/ROADMAP.md` |
| Hot-path / safety / workflow rule | this `AGENTS.md` and `.cursor/rules/` if Cursor-specific |

Do not leave docs for “later when we push.” Local Forever work still gets Unreleased notes. Push/tag still only when Babuni asks.

## Documentation and privacy standard (audit #32)

Preserve `docs/DEVELOPMENT.md` and `CHANGELOG.md` as chronological implementation evidence. Maintain explicit separation between *Zone candidate*, *Nearby observation*, *persisted personal memory*, *private flags* and *shared marks*. Do not portray subjective player labels or received votes as verified reputation facts. Never publish actual identifiable player records in the portfolio. Attribute the original social-recognition purpose to Babuni; label AI assistance, code-only findings, historic claims and newly executed tests separately.

## Repository-local documentation standard

Follow [the documentation standard](docs/DOCUMENTATION.md) for first-person author voice throughout project documentation, factual changelogs, and naming the AI tool and verified model for each contribution. These rules travel with this repository and do not depend on the babuni.dev ChatGPT Project. Preserve all project-specific technical, creative, canon, safety, licensing, and historical rules in this file; follow the linked standard for public first-person narrative, human–AI attribution, concise development journals, decision records, and evidence-based verification. **Babuni** is the human creative; **babuni.dev** is the website/portfolio, not the person. Preserve third-party credits and historical legal notices. References above to a dated “documentation-only audit” describe that past task, not a permanent ban on later authorized implementation.

## Human–AI collaboration record

`docs/AI_COLLABORATION.md` is the short record of how Babuni works with AI and who did what, with the same text in all of Babuni's repositories. Do not add dated entries, session notes or per-change attribution to it. Record each contribution in `docs/DEVLOG.md` (what Babuni asked for and what the AI did, naming the tool and model) and in `CHANGELOG.md`. Change `docs/AI_COLLABORATION.md` only to add a row to its "Who did what" table when a new AI tool or model starts contributing to this project, or when Babuni revises the shared text.

## Repository layout

The repository root holds only `README.md`, `AGENTS.md`, `LICENSE` and `CHANGELOG.md` (plus any additional license files). All other documentation lives in `docs/`; put new documents there.

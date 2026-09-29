# Documentation Review Tracker

**Temporary.** Delete this file once everything reads *Reviewed* and the cleanup tasks are done; the docs then stand on their own. If anything here turns out to be a standing convention, move it to [Contributing](../CONTRIBUTING.md) or [Ways of Working](../ways-of-working/README.md) first.

Status is blank until a doc has been through the [doc-review](../.claude/skills/doc-review/SKILL.md) pass; **Reviewed** once it has. The earlier dedupe pass ([doc-consistency](../.claude/skills/doc-consistency/SKILL.md)) is done for the whole set, so it no longer needs its own tracking here.

## Design Documents — `docs/`

Row order is the reading order; [`docs/README.md`](../docs/README.md) now carries it too, grouped by folder. Keep the two in step, and delete this table rather than the index when the review ends.

| Document | Status | Notes |
| --- | --- | --- |
| [Game Vision and Design Goals](../docs/design/game-vision-and-design-goals.md) | | |
| [Licensing and IP](../docs/decisions/licensing-and-ip.md) | Reviewed | Sections by decision area: Licensing, Inspiration Not Appropriation, No Licensed Football Content, Third-Party Asset Intake, Contributions |
| [Player Manual](../docs/manual/player-manual.md) | | Placeholder, and the next one to write. Controls are a section here, not a separate doc |
| [Visual Style Guide](../docs/design/visual-style-guide.md) | | Owns the camera framing rule and the palette-legibility constraint for showing height; the height mechanism itself is Ball Physics's. Where [2.1 Keeper Drill](milestones/2.1-keeper-drill.md) records the kit recolour approach |
| [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md) | | |
| [Pitch and Environment](../docs/design/match-engine/pitch-and-environment.md) | | Mostly placeholder. Sole owner of goal detection and post gating, under The Goal, plus Open Questions |
| [Ball Physics and Aerial Simulation](../docs/design/match-engine/ball-physics-and-aerial-simulation.md) | | The fake Z-axis, reading height visually, height-gated collision, the ball motion model, tuning over defaults, Open Questions. Goal detection is a pointer to Pitch and Environment |
| [Player Controller and Input](../docs/design/match-engine/player-controller-and-input.md) | | Turning radius, player-vs-player collision, tap vs hold, Open Questions |
| [Ball Interaction System](../docs/design/match-engine/ball-interaction-system.md) | | Ground vs lofted passing, reach radius and height, ball contention, header contention, Open Questions |
| [Team AI and Decision Making](../docs/design/match-engine/team-ai-and-decision-making.md) | Reviewed | Owns everything an AI-controlled player does relative to its anchor. Sections: Perception and Fairness; Movement, with Roles, Influence Map and Steering beneath it; Decisions, attacking and defending; The Goalkeeper; Acceptance Criteria; Open Questions |
| [Formation and Shape System](../docs/design/match-engine/formation-and-shape-system.md) | Reviewed | Owns each player's anchor — where the formation wants them to stand. Sections: Formations, The Moving Block, Wide Columns, Anchors (with the shadow formation debug view), Acceptance Criteria checked against anchors, Open Questions. What a player does relative to their anchor is Team AI's |
| [Match State Machine](../docs/design/match-engine/match-state-machine.md) | | Mostly placeholder. Match clock and periods, Open Questions |
| [Audio Design](../docs/design/audio-design.md) | | Placeholder — one line of scope |
| [CPU vs CPU Simulation](../docs/design/tournament-and-career-mode/cpu-vs-cpu-simulation.md) | | The two candidate approaches — a displayless run of the real engine, or a separate cheaper simulation — and Open Questions. Unresolved |
| [Data Architecture — Open Questions](../docs/design/tournament-and-career-mode/data-architecture-open-questions.md) | | Deferred questions grouped by scope and source, simulation and schema shape, and storage mechanics, plus a standing rule on ordered queries. Questions, not decisions |

## Process Documents — `ways-of-working/`

Substantially written, unlike most of the design set — the question here is duplication, not emptiness.

**Naming note.** [Playtesting](../ways-of-working/playtesting.md) is the current doc. Cleanup items below also mention *the original Playtesting doc*, *Development Testing Loop* and *Tuning for Feel* — none of these exist any more; their content lives in Playtesting, [Automation Testing](../ways-of-working/automation-testing.md) and `project/milestones/`.

| Document | Status | Notes |
| --- | --- | --- |
| [Ways of Working](../ways-of-working/README.md) | | Index to the folder: The Loop, The Platform Underneath, Process Notes |
| [The Spec Chain](../ways-of-working/spec-chain.md) | | How a proposal becomes work: three routes in, the gate, writing the manual entry, turning it into design, when it doesn't feel right, changing the manual, accepted but not scheduled, declined, Open Questions |
| [Playtesting](../ways-of-working/playtesting.md) | Reviewed | Sole owner of live tuning and the tuning Resource. In-editor play, the sandbox scene, live tuning, debug visualisation, session habits, Open Questions |
| [Automation Testing](../ways-of-working/automation-testing.md) | | What a test has to earn, tooling, invariants, 360 testing, determinism, threshold tests, CI, Open Questions. Per-milestone tests live in `project/milestones/`; determinism decisions in Technical Architecture and Stack |
| [Build Pipeline](../ways-of-working/build-pipeline.md) | | |
| [Gamepad Input and Steam Deck Parity](../ways-of-working/gamepad-input-and-steam-deck-parity.md) | Reviewed | Sole owner of controller setup, binding rules and Steam Input. Per-device actions for couch co-op are decided in [0.1 Input Map](milestones/0.1-input-map.md) |

## Project Documents — `project/`

These docs share how milestones work: [Project](README.md) owns the rules, [Roadmap](roadmap.md) the build order, and [Milestone Template](milestones/TEMPLATE.md) a milestone file's shape.

| Document | Status | Notes |
| --- | --- | --- |
| [Project](README.md) | Reviewed | The folder's front door. Sole owner of what a milestone is, what belongs in a milestone file versus the roadmap, the filename convention, exit criteria — three routes — and Outline → Ready |
| [Roadmap](roadmap.md) | Reviewed | The build order by phase, one line per milestone, then Notes on the Order for what spans phases — including the phase-boundary Deck build and progressive sprites |
| [Milestone Template](milestones/TEMPLATE.md) | Reviewed | A copyable skeleton. Each field carries its own omission condition; Sprites and Attributes are optional fields |
| [Ideas](ideas.md) | | |
| `milestones/` | | Not tracked individually. [0.1 Input Map](milestones/0.1-input-map.md) is Ready; the rest are Outline. [1.1](milestones/1.1-movement-and-possession.md) fixes sprite dimensions and the foot anchor alongside the world scale; [2.1](milestones/2.1-keeper-drill.md) decides how kits get recoloured. No status exists yet for a milestone that has been *built* — open |

## Known Cleanup Tasks

The duplication pass has been done as a read-through; what follows is the backlog it produced. Work top-down — the decisions change what the edits below do.

### Decide First

- [ ] **24. Is there a milestone skill, and what is left for it to do?** The rules now have a home — [Project](README.md) owns what a milestone is, how it exits, and Outline → Ready; [TEMPLATE](milestones/TEMPLATE.md) owns the shape. What is not written down anywhere is the *judgement*: choosing the reference section, keeping Asking narrow, and deciding what earns a test. That last one has a demonstrated failure — 0.1's four proposed tests all failed [Automation Testing](../ways-of-working/automation-testing.md)'s own rules, two of them asserting Godot's behaviour rather than the project's, with the rules sitting unread in a doc. The test to apply is [Ways of Working](../ways-of-working/README.md)'s own: *"The procedure lives in the skill, not in a doc here."* So: a `milestone-ready` skill walking the Outline → Ready pass with a gate on what earns a test, or two sharper cross-links and no skill? most milestone files are still to promote, so it is not a one-off
- [x] **1. Player Manual and Controls Reference: merge or keep split.** Decided: merge, controls as a clearly delineated section within Player Manual. `controls-reference.md` deleted; every doc that linked to it ([Spec Chain](../ways-of-working/spec-chain.md), [Gamepad Parity](../ways-of-working/gamepad-input-and-steam-deck-parity.md), [Ball Interaction System](../docs/design/match-engine/ball-interaction-system.md)) now points at Player Manual's controls section instead
- [x] **2. What job does Overview and Architecture have?** None it wasn't already doing worse than [`docs/README.md`](../docs/README.md)'s match-engine table. Deleted; its row and the AGENTS "eight files" count in `design/match-engine/` both updated
- [x] **3. How much restatement is wanted between README, CONTRIBUTING, AGENTS and the source docs?** Settled: the rule may repeat per audience (AGENTS loads every session, CONTRIBUTING is the outside-contributor entry point, README is the front door), but the argument may not — exactly one doc holds the reasoning and the rest link to it. This is the standing rule the `/doc-consistency` skill itself now states, so it doesn't need re-deciding per pass
- [x] **4. Six `ways-of-working/` docs each try to stand alone**, so each restates enough of its neighbours to do so. Superseded by item 3's general rule; no further action needed beyond items 5–15 below

### Merges and Single-Owner Passes — `ways-of-working/`

- [x] **5. Threshold tests were written twice.** Done, in the opposite direction to the one first proposed: [Automation Testing](../ways-of-working/automation-testing.md) owns them, because a threshold test is a test. Tuning for Feel, the other copy, no longer exists
- [x] **6. Live tuning and feel constants — three copies.** Done. [Playtesting](../ways-of-working/playtesting.md) owns the whole of it, [AGENTS](../AGENTS.md) keeps the one-line convention, and the third copy went with Tuning for Feel
- [x] **7. When to build / what to verify on hardware.** Done. The circular deferral is broken: [Roadmap](roadmap.md) owns the trigger as a milestone-boundary fact, [Build Pipeline](../ways-of-working/build-pipeline.md) owns what to verify and the two targets, and Playtesting's `When to Actually Build` section is gone rather than relinked
- [x] **8. Case-sensitivity CI check.** Done. [Build Pipeline](../ways-of-working/build-pipeline.md) owns it; [Automation Testing](../ways-of-working/automation-testing.md) now names it as the one check worth having before a pipeline exists and links rather than restating the reasoning
- [x] **9. A/B one-variable-per-session.** Done. The A/B protocol sits under Session Habits in [Playtesting](../ways-of-working/playtesting.md); Milestone 1 in the roadmap points at it rather than restating it
- [x] **10. Gamepad daily-loop parts.** Done. X-input mode and the silent mode-change trap stay solely in [Gamepad Input and Steam Deck Parity](../ways-of-working/gamepad-input-and-steam-deck-parity.md); controller-over-keyboard is a session habit and sits in [Playtesting](../ways-of-working/playtesting.md)
- [x] **11. Duplicated open questions.** Done. Playtest cadence and tuning-value location both now sit in [Playtesting](../ways-of-working/playtesting.md), which absorbed them as the original Playtesting doc and Tuning for Feel were each dissolved
- [x] **12. "What Doesn't Carry Over From Unity".** Dropped, not consolidated — all three sections deleted. The audience for a migration note is someone migrating, and this project never used Unity; only the *starter notes* were Unity-shaped, which is transitional. The durable warning survives in [AGENTS](../AGENTS.md) and the rationale in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md). The Play Mode fact was folded into Playtesting (then Development Testing Loop) before its section went

### Restatement — Root Docs

- [x] **13. The ruled-out IP list appears four times.** Checked against item 3's rule: the ruled-out bullets themselves are a deliberate per-audience repeat (AGENTS terser, CONTRIBUTING fuller) and already agree in substance — no edit needed there. The one genuine repeat was the asset-scope phrase ("sprites, audio, fonts, and content data such as name corpora and kit palette definitions"), argued independently in README, CONTRIBUTING and `licensing-and-ip.md` — and drifted (only the owner said "project-authored fonts"). Fixed: `licensing-and-ip.md` is now sole owner; README and CONTRIBUTING link to it instead of restating the scope
- [x] **14. The three-folder documentation map appears four times.** Checked against item 3's rule and against each other: this is the deliberate case the rule exists for (README as front door, AGENTS as session-loaded, CONTRIBUTING as outside-contributor entry point), and all four copies plus both folder READMEs agree in substance. No drift found, no edit made
- [ ] **15. This file's table duplicates [`docs/README.md`](../docs/README.md)'s index** — kept in step by hand. Resolves itself when the review ends and this file is deleted

### Design Set — `docs/`

- [x] **16. Height presentation written twice.** Fixed, following the actual (not declared) split: [Ball Physics and Aerial Simulation](../docs/design/match-engine/ball-physics-and-aerial-simulation.md) "Reading Height Visually" owns the shadow/sort-order mechanism; [Visual Style Guide](../docs/design/visual-style-guide.md) "Showing Height" trimmed to its genuinely unique content — the palette-legibility constraint — with a link to Ball Physics for the mechanism
- [x] **17. Goal detection written twice.** Fixed: [Pitch and Environment](../docs/design/match-engine/pitch-and-environment.md) "The Goal" is sole owner (line-crossing plus under-crossbar, posts disabled/re-enabled, the underside-of-bar edge case). Ball Physics's "Goal detection"/"Posts and frame" bullets merged into one pointer, keeping only the `set_deferred` implementation note that Pitch and Environment doesn't cover
- [x] **18. Reach radius and the head-height gate.** Checked, not fixed — already correct: Ball Physics's "Players" bullet already just cross-references [Ball Interaction System](../docs/design/match-engine/ball-interaction-system.md) for the reach-radius predicate rather than restating it. Not a duplicate
- [x] **19. Blobbing and its resolution.** [Formation and Shape System](../docs/design/match-engine/formation-and-shape-system.md) doesn't actually name "blobbing" — that suspect was already stale. The real repeat was [Team AI and Decision Making](../docs/design/match-engine/team-ai-and-decision-making.md) restating [3.2 Shape and Home Zones](milestones/3.2-shape-and-home-zones.md)'s definition ("converges on the ball… chaos rather than football") verbatim; trimmed to a link. Bumper cars in Team AI left alone — it adds a reason (looks organised in a screenshot) 3.2 doesn't have, so it's not a pure restatement
- [x] **20. "This belongs in the tuning Resource" refrain.** Checked, not fixed — it's the same general rule applied to five different constants, each already linking to [Playtesting](../ways-of-working/playtesting.md). Applying a rule to a new instance isn't restating it
- [x] **21. Milestone lists in both Roadmap and Playtesting.** Done. The original Playtesting doc was dissolved: [Roadmap](roadmap.md) was the single source with each milestone carrying its own playtest protocol inline; that content has since moved one level further, into `project/milestones/` (one file per milestone, plus [TEMPLATE](milestones/TEMPLATE.md)), with Roadmap reduced to the sequencing index. Sorting the protocols down to exit criteria is still deferred to a later pass
- [x] **22. Design pillars restated in full in AGENTS, and drifted** — AGENTS listed five pillars, splitting out "Single-button input for all actions"; [Game Vision and Design Goals](../docs/design/game-vision-and-design-goals.md), the owner, has four, with single-button input folded into "Easy to pick up, difficult to master". Fixed: AGENTS now matches the four, with single-button input merged back in, plus a link to the owner for the reasoning. "Match-first" restated near-verbatim within Game Vision itself (Scope & Boundaries paragraph vs Design Pillars bullet) — trimmed the Scope & Boundaries sentence to its unique consequence (transfers framing) and pointed at the pillar instead
- [x] **23. Resolution and ultrawide policy.** Settled on the second pass, reversing the first. Splitting policy from configuration left the process doc restating decisions it didn't own, so [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md) now owns both — the policy *and* the Project Settings values, which are set once, not done in the loop. The camera consequence was never a testing concern and moved to [Visual Style Guide](../docs/design/visual-style-guide.md). Physics tick rate went the same way: architecture keeps the constant. The `_physics_process` convention has since moved fully to architecture too, alongside injected clock and injected RNG, as one determinism decision — [Automation Testing](../ways-of-working/automation-testing.md) links to it rather than restating it

## Detail Pass — After the Backlog Above Is Clear

A separate piece of work, deliberately sequenced second. It was the third question in the original cleanup bullet — *can it be shorter* — and it is the one part of that bullet the duplication read-through did not answer.

Wait until every box above is ticked. A good share of the current length *was* the duplication: Build Pipeline and Playtesting were long largely because each carried the other's content plus a Unity section. That pair is now resolved (items 7 and 12); the rest of the set has not been measured. Doing it earlier also risks cutting the canonical copy of some reasoning while a restatement of it survives elsewhere — the dedupe is what establishes which copy is canonical.

- [ ] **Right-size what's left.** Run the [doc-review](../.claude/skills/doc-review/SKILL.md) skill per doc — the tables above track status for `docs/`, `ways-of-working/` and `project/`. Not tracked there: the individual files under `project/milestones/`, which now hold the protocols [Roadmap](roadmap.md) previously carried inline, and the SWOS research under `sources/swos/`. Of the latter, [overview.md](../sources/swos/overview.md) is **Reviewed** — restructured from a strengths/weaknesses split into Strengths, Trade-offs and Weaknesses, because several entries appeared on both lists as the same decision costed twice (low-friction career vs. no progression; editable tactics vs. the time to edit them). Each trade-off now names what it buys, what it costs, and whether the original constraint was hardware or choice — a 1990s limit we no longer have is only worth copying if it was load-bearing for the feel. The four mechanics bullets it used to carry (60fps, the tick/cross myth, the form modifier, the 0–7/+8 overflow bug) were dropped as owned by the sibling docs; the form modifier was then deleted outright from [career-mode-mechanics.md](../sources/swos/career-mode-mechanics.md) as unconfirmed by its own source and immaterial to play. Also in scope: the ~30 open questions accumulated across the design set, four or five per doc — answer, drop, or keep deliberately

Reasoning recorded once, in the doc that owns the topic, is the point and stays — `decisions/` exists to hold it. What comes out is restatement, and explanation attached to things that were never actually decided.
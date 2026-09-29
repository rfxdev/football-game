# Documentation Review Tracker

**Temporary.** Delete this file once every doc below reads *Reviewed*. If anything here turns out to be a standing convention, move it to [Contributing](../CONTRIBUTING.md) or [Ways of Working](../ways-of-working/README.md) first.

Status is blank until a doc has been through the [doc-review](../.claude/skills/doc-review/SKILL.md) pass; **Reviewed** once it has. `sources/` and `project/milestones/` are out of scope.

## Design Documents — `docs/`

Row order is the reading order, which [`docs/README.md`](../docs/README.md) also carries — keep the two in step.

| Document | Status | Notes |
| --- | --- | --- |
| [Game Vision and Design Goals](../docs/design/game-vision-and-design-goals.md) | | | | Gameplay aims only — IP and naming are Licensing and IP's, platforms Architecture's. Career mode is a placeholder; out-of-scope wording matches AGENTS |
| [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md) | | | | Owns the supported display band, the bars outside it and the viewport settings; what the player sees within the band is the Visual Style Guide's |
| [Licensing and IP](../docs/decisions/licensing-and-ip.md) | Reviewed | Sections by decision area: Licensing, Inspiration Not Appropriation, No Licensed Football Content, Third-Party Asset Intake, Contributions. §3 is a position, not a plan — no generation; its traps are worded the same in AGENTS and CONTRIBUTING |
| [Player Manual](../docs/manual/player-manual.md) | | Placeholder, and the next one to write. Controls are a section here, not a separate doc |
| [Visual Style Guide](../docs/design/visual-style-guide.md) | | Owns the camera framing rule and the palette-legibility constraint for showing height; the height mechanism itself is Ball Physics's. Where [2.1 Keeper Drill](milestones/2.1-keeper-drill.md) records the kit recolour approach | | Owns what the player sees across the display band — how much pitch is visible — and the palette-legibility constraint for showing height; the band itself is Architecture's, the height mechanism Ball Physics's. Where [2.1 Keeper Drill](milestones/2.1-keeper-drill.md) records the kit recolour approach |
| [Audio Design](../docs/design/audio-design.md) | | Placeholder — one line of scope |
| [Pitch and Environment](../docs/design/match-engine/pitch-and-environment.md) | | Mostly placeholder. Sole owner of goal detection and post gating, under The Goal, plus Open Questions |
| [Ball Physics and Aerial Simulation](../docs/design/match-engine/ball-physics-and-aerial-simulation.md) | | The fake Z-axis, reading height visually, height-gated collision, the ball motion model, tuning over defaults, Open Questions. Goal detection is a pointer to Pitch and Environment |
| [Player Controller and Input](../docs/design/match-engine/player-controller-and-input.md) | | Turning radius, player-vs-player collision, tap vs hold, Open Questions | | Input (per-player intent, deadzone as feel), turning radius, player-vs-player collision, tap vs hold, Open Questions. Tap/hold follows [1.2 Kicking](milestones/1.2-kicking.md); deadzone plumbing is Gamepad's |
| [Ball Interaction System](../docs/design/match-engine/ball-interaction-system.md) | | Ground vs lofted passing, reach radius and height, ball contention, header contention, Open Questions | | Ground vs lofted passing, reach radius and height, ball contention, header contention, Open Questions. Input scheme and heading timing follow the milestones |
| [Team AI and Decision Making](../docs/design/match-engine/team-ai-and-decision-making.md) | Reviewed | Owns everything an AI-controlled player does relative to its anchor. Sections: Perception and Fairness; Movement, with Roles, Influence Map and Steering beneath it; Decisions, attacking and defending; The Goalkeeper; Acceptance Criteria; Open Questions |
| [Formation and Shape System](../docs/design/match-engine/formation-and-shape-system.md) | Reviewed | Owns each player's anchor — where the formation wants them to stand. Sections: Formations, The Moving Block, Wide Columns, Anchors (with the shadow formation debug view), Acceptance Criteria checked against anchors, Open Questions. What a player does relative to their anchor is Team AI's |
| [Match State Machine](../docs/design/match-engine/match-state-machine.md) | | Mostly placeholder. Match clock and periods, Open Questions |
| [CPU vs CPU Simulation](../docs/design/tournament-and-career-mode/cpu-vs-cpu-simulation.md) | | The two candidate approaches — a displayless run of the real engine, or a separate cheaper simulation — and Open Questions. Unresolved |

## Process Documents — `ways-of-working/`

| Document | Status | Notes |
| --- | --- | --- |
| [Ways of Working](../ways-of-working/README.md) | | Index to the folder: The Loop, The Platform Underneath, Process Notes |
| [The Spec Chain](../ways-of-working/spec-chain.md) | | How a proposal becomes work: three routes in, the gate, writing the manual entry, turning it into design, when it doesn't feel right, changing the manual, accepted but not scheduled, declined, Open Questions |
| [Playtesting](../ways-of-working/playtesting.md) | Reviewed | Sole owner of live tuning and the tuning Resource. In-editor play, the sandbox scene, live tuning, debug visualisation, session habits, Open Questions |
| [Automation Testing](../ways-of-working/automation-testing.md) | | What a test has to earn, tooling, invariants, 360 testing, determinism, threshold tests, CI, Open Questions. Per-milestone tests live in `project/milestones/`; determinism decisions in Technical Architecture and Stack |
| [Build Pipeline](../ways-of-working/build-pipeline.md) | | | | Hardware verification cadence follows the Roadmap's phase-boundary rule |
| [Gamepad Input and Steam Deck Parity](../ways-of-working/gamepad-input-and-steam-deck-parity.md) | Reviewed | Sole owner of controller setup, binding rules and Steam Input. The per-player input seam and pad assignment are [Player Controller and Input](../docs/design/match-engine/player-controller-and-input.md)'s |

## Project Documents — `project/`

These docs share how milestones work: [Project](README.md) owns the rules, [Roadmap](roadmap.md) the build order, and [Milestone Template](milestones/TEMPLATE.md) a milestone file's shape.

| Document | Status | Notes |
| --- | --- | --- |
| [Project](README.md) | Reviewed | The folder's front door. Sole owner of what a milestone is, what belongs in a milestone file versus the roadmap, the filename convention, exit criteria — three routes — and milestone status |
| [Roadmap](roadmap.md) | Reviewed | The build order by phase, one line per milestone, then Notes on the Order for what spans phases — including the phase-boundary Deck build and progressive sprites |
| [Milestone Template](milestones/TEMPLATE.md) | Reviewed | A copyable skeleton. Each field carries its own omission condition; Sprites and Attributes are optional fields |
| [Ideas](ideas.md) | | | | Couch co-op removed — it is accepted, in the Roadmap. Links into Data Architecture, now parked alongside it |
| [Data Architecture — Open Questions](data-architecture-open-questions.md) | | Parked here from `docs/design/` — career-mode data is too early for the design set. Deferred questions grouped by scope and source, simulation and schema shape, and storage mechanics, plus a standing rule on ordered queries. Questions, not decisions |
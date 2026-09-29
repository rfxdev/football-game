# Documentation

What the game is — the decisions that bound it, the player-facing manual, and the design intent working within both. [`ways-of-working/`](../ways-of-working/README.md) covers how it gets built; [`project/`](../project/README.md) covers where the work stands.

Sections run in constraint order: the vision sets the goals, the decisions bound what can be built to meet them, the manual fixes what the player is told, and the design set works within all three. Read in that order first time.

## Vision — `design/game-vision-and-design-goals.md`

| Document | What it covers |
| --- | --- |
| [Game Vision and Design Goals](design/game-vision-and-design-goals.md) | Audience, scope boundaries, the design pillars |

Above the decisions rather than beside them: the pillars are *why* the choices below were made, so a decision that stops serving them is the decision that's wrong.

## Decisions — `decisions/`

Settled, with their reasoning recorded. Checked against rather than rewritten.

| Document | What it covers |
| --- | --- |
| [Technical Architecture and Stack](decisions/architecture-and-stack.md) | Godot 4.x, GDScript, tooling, target platforms, and why not Unity |
| [Licensing and IP](decisions/licensing-and-ip.md) | Outbound licences, why there is no licensed content, inspiration versus appropriation |

## Manual — `manual/`

| Document | What it covers |
| --- | --- |
| [Player Manual](manual/player-manual.md) | What the player is told the game does, including every control and what it does in each context |

Written **before** the design docs it describes, deliberately: settling what the player is told should inform the design set rather than summarise it afterwards.

## Design — `design/`

| Document | What it covers |
| --- | --- |
| [Visual Style Guide](design/visual-style-guide.md) | Sprite approach, palette, camera, HUD, and how height is shown |
| [Audio Design](design/audio-design.md) | Crowd, ball sounds, referee whistle |

### Match Engine — `design/match-engine/`

The playable match, in reading order. Each doc is one system.

| Document | What it covers |
| --- | --- |
| [Pitch and Environment](design/match-engine/pitch-and-environment.md) | Dimensions, boundary behaviour, the goal |
| [Ball Physics and Aerial Simulation](design/match-engine/ball-physics-and-aerial-simulation.md) | Rolling, bounce, and the fake Z-axis |
| [Player Controller and Input](design/match-engine/player-controller-and-input.md) | Movement, acceleration, turning radius, possession states |
| [Ball Interaction System](design/match-engine/ball-interaction-system.md) | Passing, shooting, tackling, loose-ball contention |
| [Team AI and Decision Making](design/match-engine/team-ai-and-decision-making.md) | Roles, influence map, steering, attacking and defending decisions, the keeper, perception and fairness |
| [Formation and Shape System](design/match-engine/formation-and-shape-system.md) | Formations, the moving block, wide-column rules, and each player's anchor |
| [Match State Machine](design/match-engine/match-state-machine.md) | Kickoff, set pieces, referee logic, the match clock |

### Tournament and Career Mode — `design/tournament-and-career-mode/`

| Document | What it covers |
| --- | --- |
| [CPU vs CPU Simulation](design/tournament-and-career-mode/cpu-vs-cpu-simulation.md) | How matches resolve when nobody is playing them |
| [Data Architecture — Open Questions](design/tournament-and-career-mode/data-architecture-open-questions.md) | What must be answered before the persistence schema and storage tech are picked |

Whether that is the match engine above running without visuals, or a second cheaper model, is unresolved and is the main open architectural question in the project. It constrains how the match engine is built, so it is a `design/` concern now rather than a career-mode one later.

*Review status for every doc here is tracked in [`project/doc-review.md`](../project/doc-review.md) — temporary, delete this line when the review ends.*

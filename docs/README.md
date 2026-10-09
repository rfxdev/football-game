# Documentation

What the game is — the vision, and the decisions that bound it. [`ways-of-working/`](../ways-of-working/README.md) covers how it gets built; [`project/`](../project/README.md) covers where the work stands.

Sections run in constraint order: the vision sets the goals, and the decisions bound what can be built to meet them. Read in that order first time.

## Vision — `design/game-vision-and-design-goals.md`

| Document | What it covers |
| --- | --- |
| [Game Vision and Design Goals](design/game-vision-and-design-goals.md) | Audience, scope boundaries, the design pillars |

Above the decisions rather than beside them: the pillars are *why* the choices below were made, so a decision that stops serving them is the decision that's wrong.

## Decisions — `decisions/`

Settled, with their reasoning recorded. Checked against rather than rewritten.

| Document | What it covers |
| --- | --- |
| [Technical Architecture and Stack](decisions/architecture-and-stack.md) | Godot 4.x, GDScript, tooling, target platforms, display, input, and why not Unity |
| [Licensing and IP](decisions/licensing-and-ip.md) | What can go into the repo and the game — licences, other games, real football, local data, third-party intake |

## Design and Manual

**The clone's design is written as far as the research reaches**, ahead of the milestones if need be — it is the reference restated, not a guess about a game nobody has played. What departs from the reference waits until the clone plays, per the [Roadmap](../project/roadmap.md), and the manual is still written per milestone, per [The Spec Chain](../ways-of-working/spec-chain.md#writing-the-manual-entry). They are the source of truth: until the clone plays, most of what they say is written from [the SWOS research](../sources/swos/), but once it's here it's ours, and nothing is judged against SWOS directly — see [Writing From SWOS](../ways-of-working/spec-chain.md#writing-from-swos). The docs written before the milestones are in [`archive/`](../archive/): not current, and a quarry rather than a template.

Every system has one owning doc, listed below whether it's written yet or not, so a proposal always has somewhere to land — see [Turning It Into Design](../ways-of-working/spec-chain.md#turning-it-into-design). An unwritten doc is named with the milestone that first needs it. A doc is split when part of it starts being read on its own, in a different task — not before.

- **A system's doc covers how it is shown as well as how it works.** Whoever builds a system is the one reading how it looks, so its animation, markers and on-screen feedback sit with it
- **Only the rules every match sprite is drawn to sit apart**, in [Sprites](design/match-engine/sprites.md)

### Manual

What the player is told, settled before the design that delivers it, per [The Spec Chain](../ways-of-working/spec-chain.md).

| Document | What it covers |
| --- | --- |
| Player Manual — the first milestone on the *told* route | What the player is told, controls first |

### Match Engine — `design/match-engine/`

One doc per system, whether it mostly simulates or mostly shows.

| Document | What it covers |
| --- | --- |
| [Sprites](design/match-engine/sprites.md) | Pixel scale and sharpness, and the placeholders a fresh clone draws. Sprite dimensions and the foot anchor once [1.1](../project/milestones/1.1-movement-and-possession.md) fixes them |
| [Pitch and Environment](design/match-engine/pitch-and-environment.md) | The pitch's lines, which surface a match is played on and its grass, and the goal — its shape, detection and drawing |
| [Camera](design/match-engine/camera.md) | View size and the aspect band, where the view stops, the ground beyond the lines, how the camera follows play |
| [Kits](design/match-engine/kits.md) | Kit data, shirt types, keepers, recolouring, clashes |
| [Ball Physics and Aerial Simulation](design/match-engine/ball-physics-and-aerial-simulation.md) | How the ball moves — steering, fake height, each surface, stopped-play walls, the goalframe — and how height reads on screen |
| [On-the-Ball Mechanics](design/match-engine/on-the-ball-mechanics.md) | Input as intent, movement and turning, carrying and possession, kicking — tap versus hold and aftertouch — the action button's slide and headers, the passive duel, fouls, same-tick contacts, control switching and its marker, and how each is animated |
| Team AI and Decision Making — [2.1](../project/milestones/2.1-keeper-drill.md) | Perception and fairness, movement, decisions, the keeper, and its debug view |
| [Formation and Shape System](design/match-engine/formation-and-shape-system.md) | Formations on the grid, the moving block, anchors, and the shadow formation that shows them |
| Match State Machine — [5.1](../project/milestones/5.1-kick-off.md) | Clock, periods, restarts, cards and injuries, and how each is shown — celebrations, cards, an injured player |
| Match HUD — [5.5](../project/milestones/5.5-clock-halves-and-full-time.md) | Score, clock and team names on screen |

### Outside the Match

Docs and their split are decided as each is scheduled.

- **CPU vs CPU simulation** — results for matches nobody watches, which season mode in [Career](../project/ideas/career.md) needs. Not the headless test harness, which is [Automation Testing](../ways-of-working/automation-testing.md)'s
- **Front end and menus** — the first of it is [7.1 Team Select](../project/milestones/7.1-team-select.md)
- **Options, audio**

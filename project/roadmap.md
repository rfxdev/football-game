# Roadmap

The build order for a SWOS clone, arranged so something is playable at every phase — which keeps solo-dev motivation up, and keeps a new problem down to one candidate explanation. Original design, meaning anything that departs from the reference, waits until the clone plays; ideas for it go in [Ideas](ideas.md).

How a milestone file works — what it is, how it exits, Outline to Ready — is in the [project README](README.md). Cross-phase notes are after the phases.

## Phase 0 — Groundwork

**The project builds, runs on the Deck, takes input, and has a test harness.**

- [0.1 Input Map](milestones/0.1-input-map.md) — abstract bindings, the 8BitDo verified against what the device actually reports
- [0.2 Sandbox Scene](milestones/0.2-sandbox-scene.md) — a fixed 1280×800 frame, a ball with height and a shadow, boundary detection with scenario reset
- [0.3 Ball Physics Test Suite](milestones/0.3-ball-physics-test-suite.md) — GdUnit4 over the fake-Z ball, from day one
- [0.4 Deck Build](milestones/0.4-deck-build.md) — one Linux build onto the Deck, before any real content exists

## Phase 1 — Skills

**One player, no opposition, every on-ball action works.**

- [1.1 Movement and Possession](milestones/1.1-movement-and-possession.md) — running, turning, picking the ball up, and what carrying it costs
- [1.2 Kicking](milestones/1.2-kicking.md) — tap for a pass, hold for a shot or lob, with aftertouch
- [1.3 Contextual Action](milestones/1.3-contextual-action.md) — slide below chest height, header above it

## Phase 2 — Contest

**Someone is trying to stop you, and contesting the ball resolves fairly.**

- [2.1 Keeper Drill](milestones/2.1-keeper-drill.md) — 1v1 against a keeper that holds its line. First opposition of any kind
- [2.2 Two Attackers](milestones/2.2-two-attackers.md) — 2v1, the first teammate, and control switching
- [2.3 Tackling](milestones/2.3-tackling.md) — slide tackles, passive duels, and foul detection

## Phase 3 — Team

**Five-a-side that reads as football.**

- [3.0 Pitch and Camera](milestones/3.0-pitch-and-camera.md) — a real pitch, and a camera that follows the ball across it. The first time the world is bigger than the frame
- [3.1 Dumb Five a Side](milestones/3.1-dumb-five-a-side.md) — every AI player runs at the ball and kicks it goalward. Deliberately stupid
- [3.2 Shape and Home Zones](milestones/3.2-shape-and-home-zones.md) — a 2×2 formation grid that follows the ball; the blob resolves into something recognisable
- [3.3 Decision Loop](milestones/3.3-decision-loop.md) — pass, shoot or dribble. Crude but legible
- [3.4 Keeper AI](milestones/3.4-keeper-ai.md) — the keeper becomes a real player

## Phase 4 — Eleven a Side

**Full pitch, full team, real formations.**

- [4.1 Eleven a Side](milestones/4.1-eleven-a-side.md) — full-size pitch, a 4-4-2 on the 5×5 grid
- [4.2 Extra Formations](milestones/4.2-extra-formations.md) — the rest of the formation set, as grid layouts

## Phase 5 — The Match

**It is a match, not a drill — play stops, restarts, and ends.**

- [5.1 Kick-off](milestones/5.1-kick-off.md) — the restart every scenario starts with
- [5.2 Out of Play](milestones/5.2-out-of-play.md) — throw-ins, corners, goal kicks
- [5.3 Free Kicks and Penalties](milestones/5.3-free-kicks-and-penalties.md) — the restart for fouls detected at 2.3
- [5.4 Cards and Injuries](milestones/5.4-cards-and-injuries.md) — yellows, reds, sendings-off, in-match injuries
- [5.5 Clock, Halves and Full Time](milestones/5.5-clock-halves-and-full-time.md) — the match as a whole having structure

## Phase 6 — Team Management

**Players differ, and you choose who plays and how — before a match and during one.** Where the project first departs from the reference on purpose.

- [6.1 Squads](milestones/6.1-squads.md) — players with their own ratings, and teams built from them
- [6.2 Team Management](milestones/6.2-team-management.md) — pick a formation, place players on its grid, substitutions and formation changes mid-match

---

## Notes on the Order

Only what spans phases. Everything milestone-specific is in the milestone's own file.

- **A phase boundary is a capability, not a container.** Milestones get split, inserted and reordered inside a phase without the boundary moving, because the boundary is the claim the phase ends on
- **A Steam Deck build happens at each phase boundary, and not otherwise** — a build per milestone would batch platform surprises up instead of surfacing them one at a time. See [Build Pipeline](../ways-of-working/build-pipeline.md)
- **Scenario reset carries Phases 0 through 4.** The ball crossing a boundary resets the scenario. That is a predicate and a reset — no wall physics to model, nothing to tune, and no throwaway work, because the predicate is the same one Phase 5 needs. One cheap mechanism defers the entire restart system until the formation system can answer where everyone stands
- **Detection lands with the mechanic; ceremony lands with The Match.** Boundary and goal detection in 0.2, foul detection in 2.3, and every restart they trigger in Phase 5. Without this rule, fouls drag the whole restart system forward into Phase 2
- **The game is playable throughout but is not a match until Phase 5.** Eleven a side that resets on out-of-play is perfectly playable, just arcade-ish. This is deliberate, not an oversight
- **Attributes get wired in as each mechanic is built, not bolted on later.** The reference bakes them into the formulas — the speed table, the ball-control turn threshold, tackling downtime. Cloning a mechanic means cloning its attribute dependency. What is deferred is squads of *differentiated* players, not attributes themselves — those arrive at [6.1 Squads](milestones/6.1-squads.md). Each milestone's Attributes field lists what it reads
- **Sprites arrive with the milestone that first needs them, at final dimensions with rough art.** Size, anchor and frame timing are right from the first frame drawn; polish is what waits. A mechanic judged against a rectangle has to be judged again once it has a body, and the reference's own sprites are off-limits under [Licensing and IP](../docs/decisions/licensing-and-ip.md), so deferring saves no drawing. Frames fit inside the reference's timings rather than setting them, and never change the hitbox — SWOS has no animation to wait out and one hitbox per player, per *Engine Performance* in [Match Mechanics](../sources/swos/match-mechanics.md). Each milestone's Sprites field lists what it draws

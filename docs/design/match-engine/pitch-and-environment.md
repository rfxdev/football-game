# Pitch and Environment

The pitch as the simulation reads it: where its lines are, its surface, and the goal. How much of it the camera shows, where the camera stops, and the ground beyond the lines are [Camera](camera.md)'s.

## The Pitch

- **One world unit is one reference pixel, so the pitch is the reference's numbers unchanged**, per [Architecture and Stack](../../decisions/architecture-and-stack.md):
  - Playing area 510 × 641 — touchlines at x 81 and 590, goal lines at y 129 and 769
  - Centre spot at (336, 449)
  - Penalty areas from x 193 to 478, reaching from the goal line to y 216 at the top and 682 at the bottom
- **One pitch for every match.** Five-a-side plays on it from [3.0](../../../project/milestones/3.0-pitch-and-camera.md); eleven a side adds players, not pitch
- **Lines are constants, not derived from anything drawn.** The goal lines in particular sit where they sit regardless of how far the world extends past them, and [5.2 Out of Play](../../../project/milestones/5.2-out-of-play.md) inherits them

**Acceptance criteria:**

- Every line, spot and box edge sits at its constant, to the unit — exact tests
- Boundary and goal predicates read the constants, never a sprite's or map's size

*Derived from: Pitch and View, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Pitch Conditions

Every match is played on one of seven surfaces, frozen to hard. Everything up to [7.2 Pitch Conditions](../../../project/milestones/7.2-pitch-conditions.md) plays on normal; 7.2 adds the other six.

- **A condition sets three ball values and the grass colour — nothing else.** No player value reads it
- **Ground friction is a multiple of normal's**, applied only while the ball rolls loose. A ball a player has slows as it would on normal, whatever the surface. A ratio needs no tick conversion and holds whatever normal is tuned to
- **A bounce takes a fraction of the ball's speed along the ground and keeps a fraction of its vertical speed.** Per bounce, not per tick, so these need no conversion either
- **Normal's values are the ones every earlier milestone tunes.** Keep the three as their own values in the tuning Resource, so another condition swaps them rather than editing code
- **A condition is picked before kick-off, or drawn at random** — 5/5/10/20/30/20/10%, frozen to hard. Drawing by month needs a calendar the game doesn't have yet
- **Each grass colour keeps the ball's shadow legible**, per [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md#showing-height)

| | Frozen | Muddy | Wet | Soft | Normal | Dry | Hard |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Ground friction, × normal | 0.875 | 1.125 | 1.1875 | 1 | 1 | 0.9375 | 0.9375 |
| Ground speed lost per bounce | 9.375% | 31.25% | 31.25% | 28.125% | 25% | 15.625% | 12.5% |
| Vertical speed kept per bounce | 65.625% | 56.25% | 59.375% | 59.375% | 62.5% | 65.625% | 68.75% |

**Acceptance criteria:**

- Each condition's three values match the table — exact tests
- The same inputs on any two conditions leave every player in the same place, and a ball a player has slows the same
- Every grass colour keeps the shadow readable at every height — judged by eye

*Derived from: Pitch Conditions, [Match Mechanics](../../../sources/swos/match-mechanics.md) — the Amiga's values, per [Writing From SWOS](../../../ways-of-working/spec-chain.md#writing-from-swos).*

*Departs from SWOS: ground friction is scaled from normal's rather than added to it, which matches the reference while normal keeps its value and stays sensible if normal is retuned; and there is no draw by month until the game has a calendar.*

## The Goal

The goal is the fiddliest object on the pitch: the only place where fake height, the 2D collision world and sprite sorting all have to agree at once.

- **Goal detection is two conditions.** The ball crosses the goal line between the posts, below the crossbar. Crossbar height is a constant in the tuning Resource, not modelled geometry. The complexity in scoring lives in the surrounding match state, not in this test
- **Posts are height-gated colliders.** Short collision shapes on the goal line, disabled while the ball is above crossbar height so it can fly over, re-enabled as it drops. Toggle them with `set_deferred` — changing a collider mid-step fights Godot's physics
- **The net is layered sprites, not depth.** Front post and bar, middle net, back net, sorted so the ball is drawn inside the net once it crosses the line. It uses the sort-order override that height already uses, per [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height)
- **The goal line is also the byline.** Goal detection and out-of-play detection read the same crossing and must not disagree about it — a shared predicate, and a concern of the match state machine as much as of geometry

**Acceptance criteria:**

- Every crossing of a goal line is exactly one of a goal or out of play — never both, never neither
- A ball over the bar never touches a post; a ball dropping off the underside of the bar bounces off it or goes in, never passes through
- Once over the line, the ball draws behind the front post and bar and in front of the back net

## Open Questions

- **Goal width and crossbar height aren't researched yet.** Neither is in [Match Mechanics](../../../sources/swos/match-mechanics.md); measure them before [2.1 Keeper Drill](../../../project/milestones/2.1-keeper-drill.md) draws the goalmouth
- **Is the crossbar one height for the whole goal**, or does the top of the net need its own value for the sorting to look right?
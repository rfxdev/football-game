# Pitch and Environment

The pitch as the simulation reads it: where its lines are, which surface a match is played on, and the goal. How much of it the camera shows, where the camera stops, and the ground beyond the lines are [Camera](camera.md)'s.

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

- **A condition sets the grass colour and three ball values — nothing else.** The ball values and what they do are [Ball Physics](ball-physics-and-aerial-simulation.md#pitch-conditions)'s. No player value reads it
- **A condition is picked before kick-off, or drawn at random** — 5/5/10/20/30/20/10%, frozen to hard. Drawing by month needs a calendar the game doesn't have yet
- **The grass colour is a palette swap**, one per condition
- **Each grass colour keeps the ball's shadow legible**, per [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height)

**Acceptance criteria:**

- The same inputs on any two conditions leave every player in the same place
- Every grass colour keeps the shadow readable at every height — judged by eye

*Derived from: Pitch Conditions, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: no draw by month until the game has a calendar.*

## The Goal

The goal's shape is constants beside the pitch lines, and the ball is tested against them each tick rather than against a collision shape. What the ball does when it meets the frame or the net is [The Goalframe](ball-physics-and-aerial-simulation.md#the-goalframe)'s.

- **A goal is the ball crossing the goal line between x 303 and 367, no higher than 15**, tested on the tick it crosses. Any other crossing is out of play, so the goal line is also the byline: one predicate, read by both
- **The frame spans x 297 to 373 and stands 19 high.** The posts are 297–302 and 368–373; the bar is the band from 16 to 19 over the mouth
- **The box behind the line runs back to y 113 at the top and 784 at the bottom**, as wide and as high as the frame. Its roof is at 15, except in the back of the top goal, from 6 behind the line, where it drops to 10; the bottom goal's is flat. The back netting is at y 119 at the top and 778 at the bottom
- **The two goals aren't mirrored** — the top goal is a unit deeper, with the sloping roof. Kept as the reference has it

**Drawn into the ground, with a sprite over each goal** layered by ground position like every other, per [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height):

- **Both goals are drawn whole on the ground** — posts, bar, netting and their shadow, cast the same way as the ball's
- **The top goal's sprite is its bar**, layered at the goal line. **The bottom goal's is the whole goal again** — bar, posts and net mesh — layered at its back netting
- **So a ball inside either goal draws under its sprite** — under the top bar, behind the bottom goal's mesh — and over the ground's posts and netting. In front of the line it draws over both sprites

**Acceptance criteria:**

- Every crossing of a goal line is exactly one of a goal or out of play — never both, never neither
- The goal predicate holds at its corners — x 303 and 367, height 15 and 16 — exact tests
- A ball inside either goal draws under that goal's sprite; in front of the line, over it

*Derived from: The Goal, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

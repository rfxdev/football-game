# Ball Physics and Aerial Simulation

## At a Glance

- **The ball steers toward a point, re-aimed every tick.** Moving the point is what steers it — [Ball Movement](#ball-movement)
- **Height is faked.** The ball carries its own height and vertical speed outside the engine's physics, falling and bouncing until it rolls — [Fake Height](#fake-height)
- **Height is shown by drawing the ball raised above a fixed shadow.** The gap between them is what the player reads — [Showing Height](#showing-height)
- **The surface changes how the loose ball rolls and bounces**, and nothing else — [Pitch Conditions](#pitch-conditions)
- **The posts, bar and net turn the ball back** by moving the point it heads for — [The Goalframe](#the-goalframe)
- **Walls exist only while play is stopped.** In play, leaving the pitch is out of play — [Stopped Play](#stopped-play)

Speeds are in world units per second, and their changes per second each second.

## Ball Movement

- **The ball heads for a point, re-aimed every tick.** It never stores a heading of its own: each tick, the offset from ball to point picks one of 256 directions, and the ball steps that way at its speed
- **A direction is linear within each eighth of a turn, not a true angle.** The offset is taken between whole units, and both parts are halved, rounding down, until each is under 32 world units. The direction's angle from the nearer axis is then 32 × the smaller part ÷ the larger, rounded, in 256ths of a turn — so halfway between an axis and a diagonal the ball heads about 4° nearer the axis
- **A step is the speed times the direction's sine and cosine, each cut to 128ths, rounding down.** Rounding down takes a negative part away from zero, so along +x or +y the ball covers 127/128 of its speed, and along −x or −y all of it
- **A ball at its point doesn't move**, and keeps its speed — only slowing takes any off
- **A fixed point gives a straight line along an axis; moving the point bends the path.** Off an axis each re-aim is a little off the true direction, so the path bends slightly by itself — a few units over a pitch length on a kick's diagonal, more at other angles. Aftertouch moves it, per [Kicking](on-the-ball-mechanics.md#kicking), and so does a rebound off the frame, per [The Goalframe](#the-goalframe)
- **A kick sets the point far past the pitch** — 1000 out along each axis it travels. A pass to a teammate aims at them, stretched to just past the pitch edge. Set pieces have their own points
- **The ball moves itself, not a `RigidBody2D`.** Position, heading and height are integrated by its own code each physics tick, so steering, friction and bounce are exactly what this doc says

**Acceptance criteria:**

- A ball heading along an axis travels in a straight line
- The direction picked for every offset follows the rule above, and a step's size the rounding — exact tests
- Moving the point mid-flight bends the path toward it; along an axis, nothing else moves the ball off its line
- A ball at its point stays there

*Derived from: Ball Movement, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Fake Height

- **Height is a float the ball owns, outside Godot's physics**, with its own vertical speed. Nothing in the engine maintains it, so anything that cares about height has to check it
- **Gravity pulls the ball down once it has left the ground** — about 176 off the vertical speed, every tick it starts above the ground. A kick or a bounce lifts it at its full vertical speed, and gravity starts the tick after
- **Below zero, the ball bounces.** Height goes back to 0 and the pitch's fractions come off its ground and vertical speed, per [Pitch Conditions](#pitch-conditions). A bounce that leaves 31 or less of vertical speed ends it, and the ball rolls
- **The ball slows less in the air than on the ground** — by about 49 in the air, 78 on the ground, plus the pitch's friction while it's loose. Pitch friction doesn't apply in the air. Otherwise ground movement ignores height
- **A keeper holds the ball at a fixed height** — 5, rising to it at 100 or falling at 50

**Acceptance criteria:**

- A dropped ball bounces lower each time and comes to rest rolling, never jittering at 0
- Ground speed falls at the air rate at every height above 0
- Gravity, both slowdowns and the bounce cut-off match their values — exact tests

*Derived from: Ball Height, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: SWOS runs gravity while the vertical speed isn't zero, so it pulls on a ball the tick it's kicked up or bounces, and leaves one let go in the air with none hanging there. Here gravity waits until the ball has left the ground, and a dropped ball falls — the simpler rule. Each arc runs about a tick longer, which plays the same.*

## Showing Height

A top-down view can't show height directly, and aerial play runs through the whole game. The raised sprite and the shadow carry it, and the ball's roll shows it moving; this section covers what they ask of the look.

- **The ball and its shadow are each 4 × 4 world units, placed by the unit one in from the left on the bottom row**, per [Sprites](sprites.md#placeholders)
- **The ball is drawn its height higher up the screen** than its ground position
- **The shadow is one fixed image, never scaled.** It sits right of the ball's ground position by half the height and below it by a quarter, each in whole units rounded down, plus one more unit each way — one right and one below at rest — as if lit from the upper left
- **Sprites layer by ground position alone, ignoring height.** A high ball passing a player who stands lower on screen is drawn behind them. The shadow layers 10 further up the screen than it's drawn, so it goes under the sprites near it
- **The shadow stays legible against every pitch colour the palette uses.** The player reads height from the gap between ball and shadow, not from the ball, so shadow-against-ground contrast constrains the palette rather than following it
- **A moving ball rolls through four frames, faster the faster it goes; a still ball shows one.** Moving means a step on either axis. A frame lasts:

| Ground speed, world units a second | Under 50 | Under 100 | Under 250 | 250 and over |
| --- | --- | --- | --- | --- |
| Frame lasts, seconds | 0.12 | 0.06 | 0.04 | 0.02 |

**Acceptance criteria:**

- The ball's and shadow's drawn positions are exact functions of height — exact tests
- A rolling ball holds each frame for its speed's time, to the tick — exact tests
- The ball layers at its ground position at every height, and the shadow 10 further up the screen than it's drawn — exact tests

*Derived from: Ball Height, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Pitch Conditions

The surface changes how the ball rolls and bounces. Which surface a match is played on is [Pitch and Environment](pitch-and-environment.md#pitch-conditions)'s; everything up to [7.2 Pitch Conditions](../../../project/milestones/7.2-pitch-conditions.md) plays on normal.

- **The pitch adds to normal's ground friction**, only while the ball rolls loose. A ball a player has slows as it would on normal, whatever the surface
- **A bounce takes a fraction of the ball's speed along the ground and keeps a fraction of its vertical speed.** Per bounce, not per tick, so these need no conversion
- **Normal's values are the ones every earlier milestone tunes.** Keep the three as their own values in the tuning Resource, so another condition swaps them rather than editing code

| | Frozen | Muddy | Wet | Soft | Normal | Dry | Hard |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Added to ground friction | −9.8 | +9.8 | +14.6 | 0 | 0 | −4.9 | −4.9 |
| Ground speed lost per bounce | 9.375% | 31.25% | 31.25% | 28.125% | 25% | 15.625% | 12.5% |
| Vertical speed kept per bounce | 65.625% | 56.25% | 59.375% | 59.375% | 62.5% | 65.625% | 68.75% |

**Acceptance criteria:**

- Each condition's three values match the table — exact tests
- A ball a player has slows the same on every condition

*Derived from: Pitch Conditions, [Match Mechanics](../../../sources/swos/match-mechanics.md) — the Amiga's values, per [Writing From SWOS](../../../ways-of-working/spec-chain.md#writing-from-swos).*

## The Goalframe

From [2.1 Keeper Drill](../../../project/milestones/2.1-keeper-drill.md), which adds posts and a net. Where the frame, roof and netting are is [The Goal](pitch-and-environment.md#the-goal)'s.

**The posts and bar** meet the ball in play only, in the four rows just inside the goal line, before it crosses:

- **A high ball hits the bar; otherwise, outside the mouth, a post** — the bar above 15. Above 19 it passes over the frame untouched
- **A ball moving at the goal is turned back toward the pitch, then nudged sideways.** One already moving away is left alone
- **A ball running along the line** — up or down the pitch at about 16 or less — has its vertical speed flipped by the bar. A post turns it back, then nudges how steeply
- **Turning back mirrors the point the ball heads for**, per [Ball Movement](#ball-movement), so it leaves at the angle it came in
- **The nudge moves that point by the tick count, not at random** — by −256 to +240, up to about 16–20° on a shot, more on a pass, whose point is nearer. The clock is the injected tick-derived one, per Determinism in [Architecture and Stack](../../decisions/architecture-and-stack.md)
- **Every hit keeps most of the speed** — 75% — ends any aftertouch, and puts the ball back where it was at the start of the tick

**Inside the goal** — at any time, in the box behind the line:

- **Into the roof from below, the ball stops dead and drops; onto it from above, it rolls off the back** — at 50, keeping its height
- **The side netting**, either side of the mouth, turns the ball back across the pitch at a quarter of its speed
- **The back netting** turns it back up or down the pitch at an eighth
- **Either netting ends any aftertouch and puts the ball back** where it was at the start of the tick

**Acceptance criteria:**

- A ball above the frame never touches it; one in the bar's band crossing the front rows always hits the bar
- A post or bar hit and each netting keep exactly the share of speed given above — exact tests
- The ball never leaves the goal through its netting or roof
- The same inputs give the same deflection off the frame
- A ball square on to the frame, with no nudge, leaves at exactly the angle it came in

*Derived from: The Goal, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Stopped Play

From [5.2 Out of Play](../../../project/milestones/5.2-out-of-play.md); until then a ball leaving the pitch resets the scenario, per [0.2](../../../project/milestones/0.2-sandbox-scene.md).

- **While play is stopped, walls keep the ball near the pitch** — at x 53 and 618 and y 100 and 799, about 28 outside each touchline and 30 behind each goal line. A ball crossing one is put back where it was that tick, reversed on that axis, and its speed halved
- **In play there are no walls.** Leaving the pitch is out of play, never a rebound

**Acceptance criteria:**

- While play is stopped the ball never crosses a wall; in play it crosses their lines freely

*Derived from: Ball Height, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Open Questions

- **What unit are SWOS's ball slowdowns and pitch friction in?** Ball Height and Pitch Conditions in [Match Mechanics](../../../sources/swos/match-mechanics.md) give them per tick with no scale; 78, 49 and the friction row assume 1/512 of a pixel a tick. Research it into `sources/` so the values can be checked
- **Does the ball bounce off players in SWOS**, beyond being controlled, tackled or headed? Not researched
- **Does a jumping player get a height, and a shadow?** Not researched — the header's frames may show the jump on their own. A reference player's shadow is part of each frame, not a sprite of its own, per Sprite Data in [Match Mechanics](../../../sources/swos/match-mechanics.md)

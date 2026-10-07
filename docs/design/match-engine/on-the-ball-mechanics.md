# On-the-Ball Mechanics

What the player's input does to their player and the ball. Sections arrive with the milestones that need them; the doc's full scope is in the [design index](../../README.md). Bindings and the pad itself are [Deck Input Parity](../../../ways-of-working/deck-input-parity.md)'s.

Speeds are in world units — the reference's pixels, per [Architecture and Stack](../../decisions/architecture-and-stack.md) — per second.

## Input as Intent

- **Game code reads a per-player intent — a direction and the action — never a device.** One player uses it until two-player mode, which gives each player a pad behind the same seam without touching anything that reads intent
- **The direction is one of eight, or none**, as on the reference's digital joystick. The stick is snapped to the nearest eighth before anything reads it
- **The stick deadzone is a feel value owned here.** It sets how far the stick moves before a direction registers: too large and a small adjustment needs a shove that overshoots, too small and a resting stick drifts. Set per action in the Input Map and tuned on the pad, from [1.1 Movement and Possession](../../../project/milestones/1.1-movement-and-possession.md)

## Movement

- **Speed sets top running speed:** 91, 95, 100, 104, 109, 113, 118, 122 from Speed 0 to 7 — about a 35% swing
- **Turning is instant, on the ball and off it.** A player faces and runs the stick's direction on the tick it changes. No turning circle and no animation to wait out — the reference leans on reflexes, not momentum. No attribute reads it; what turning on the ball costs is [Carrying the Ball](#carrying-the-ball)'s
- **Players aren't solid to each other.** Bodies pass through one another, teammates and opponents alike; players only contest each other through the ball

*Derived from: Movement and Engine Performance, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Carrying the Ball

- **A player takes the ball by running onto it** — within 5.7 of it (a squared distance of 32), the ball no higher than 12, the stick held in a direction. With the stick centred they stop, and the ball isn't carried
- **Carrying cuts speed to 87.5%** for everyone — 79, 83, 87, 91, 95, 99, 103, 107 from Speed 0 to 7
- **The ball runs just ahead of the carrier's feet.** On a pattern of two ticks on and two off, it is set to the carrier's speed plus an offset from Ball Control: 13, 11, 10, 9, 7, 6, 4, 3 from Ball Control 0 to 7. Low control lets it run further ahead. The pattern stays two and two at our tick rate, per [Writing From SWOS](../../../ways-of-working/spec-chain.md#writing-from-swos)
- **After a turn, the ball swings round to catch up.** While it sits 90° or more off the carrier's facing, it runs a further 25 faster until it's back in front. This is what turning on the ball costs unopposed, and whether it reads as *skill* or as *sluggishness* is what [1.1](../../../project/milestones/1.1-movement-and-possession.md) is judging
- **Changing direction too often loses touch — but only under pressure.** Each change of direction on the ball counts, and centring the stick on the ball resets the count. At 4, 5, 6, 8, 11, 14, 17 or 21 changes, from Ball Control 0 to 7, the carrier loses touch for 10 ticks and the ball runs on loose — if an opponent's player is within 8.5 of the ball. Unopposed, the count climbs and costs nothing

*Derived from: Movement and Ball Control, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Acceptance Criteria

- The same intent produces the same movement from keyboard and pad
- The player faces and moves in the stick's new direction on the tick it changes, with the ball and without
- Top speed matches the table at every Speed, and carrying gives exactly 87.5% of it
- The player takes the ball exactly when within 5.7, with the ball at 12 or lower and the stick held, and not otherwise
- The catch-up boost applies exactly while the ball is 90° or more off the carrier's facing
- With an opponent within 8.5 of the ball, touch is lost on exactly the change of direction the table gives at every Ball Control, and not before; without one, never. Centring the stick on the ball resets the count
- **Judged by playing:** a player can be nudged a few world units to line up with the ball without overshooting, and a resting stick never moves them

# On-the-Ball Mechanics

What the player's input does to their player and the ball. Each section names the milestone that first builds it; the doc's full scope is in the [design index](../../README.md). Bindings and the pad itself are [Deck Input Parity](../../../ways-of-working/deck-input-parity.md)'s.

Speeds are in world units — the reference's pixels, per [Architecture and Stack](../../decisions/architecture-and-stack.md) — per second, and durations in seconds.

## Input as Intent

From [1.1 Movement and Possession](../../../project/milestones/1.1-movement-and-possession.md).

- **Game code reads a per-player intent — a direction and the action — never a device.** One player uses it until two-player mode, which gives each player a pad behind the same seam without touching anything that reads intent
- **The direction is one of eight, or none**, as on the reference's digital joystick. The stick is snapped to the nearest eighth before anything reads it
- **The stick deadzone is a feel value owned here.** It sets how far the stick moves before a direction registers: too large and a small adjustment needs a shove that overshoots, too small and a resting stick drifts. Set per action in the Input Map and tuned on the pad

## Movement

From [1.1](../../../project/milestones/1.1-movement-and-possession.md).

- **Speed sets top running speed:** 91, 95, 100, 104, 109, 113, 118, 122 from Speed 0 to 7 — about a 35% swing
- **Turning is instant, on the ball and off it.** A player faces and runs the stick's direction on the tick it changes. No turning circle and no animation to wait out — the reference leans on reflexes, not momentum. No attribute reads it; what turning on the ball costs is [Carrying the Ball](#carrying-the-ball)'s
- **Players aren't solid to each other.** Bodies pass through one another, teammates and opponents alike; players only contest each other through the ball

*Derived from: Movement and Engine Performance, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the stick is read every tick, not every other, so a turn lands on the tick the stick moves — per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Players not being solid is decided here; the research doesn't cover bodies meeting.*

## Carrying the Ball

From [1.1](../../../project/milestones/1.1-movement-and-possession.md); the pressure rule is judged at [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A player takes the ball by running onto it** — within 5.7 of it (a squared distance of 32), the ball no higher than 12, the stick held in a direction. With the stick centred they stop, and the ball isn't carried
- **Carrying cuts speed to 87.5%** for everyone — 79, 83, 87, 91, 95, 99, 103, 107 from Speed 0 to 7
- **The ball runs ahead in touches.** Carried, it creeps ahead of the carrier until it's out of reach, runs loose for a moment, and is caught again. It creeps at 5.6, 4.9, 4.2, 3.5, 2.8, 2.2, 1.5, 0.8 from Ball Control 0 to 7 — a poor dribbler is out of reach about every second, a good one every several. The reference gets there by setting the ball to the carrier's speed plus a Ball Control offset on two ticks in four, less a little friction each tick; resetting it every tick, per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md), changes that sum, so the creep is the target and the mechanism is tuned to it
- **A turn while the ball is out of reach leaves it behind.** Only a ball in reach turns with the carrier; a loose one keeps going the old way. This is how a poor dribbler loses the ball with nobody near, and why turning on the ball is a matter of timing. Whether a lost ball reads as the player's mistake or the game's is what [1.1](../../../project/milestones/1.1-movement-and-possession.md) is judging
- **After a turn, the ball swings round to catch up.** While it sits 90° or more off the carrier's facing, it runs a further 25 faster until it's back in front
- **Under pressure, changing direction too often loses touch too.** Each change of direction on the ball counts once the new direction has held for 2 ticks, and centring the stick on the ball resets the count. The hold stands in for the reference reading the stick only every other tick, which let a quick roll past a diagonal go uncounted — whether 2 is enough is judged at 1.1. At 4, 5, 6, 8, 11, 14, 17 or 21 changes, from Ball Control 0 to 7, the carrier loses touch for 19 ticks and the ball runs on loose — if an opponent's player is within 8.5 of the ball. Unopposed the count climbs without cost, so a player who has weaved freely can meet a challenge already over the limit

*Derived from: Movement and Ball Control, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the creep is held to the reference's rate but reached by a different sum, since the ball is reset every tick rather than every other; and a change of direction counts only once held for 2 ticks, standing in for the reference reading the stick at half the rate. Both follow *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md).*

## Kicking

From [1.2 Kicking](../../../project/milestones/1.2-kicking.md).

- **On the ball, tap passes and hold shoots or lobs.** One button, no modifier
- **Aftertouch is relative to the kick's own direction**, never absolute up or down, and it fades — the sooner the stick moves after the kick, the bigger the effect
- **On a shot:** stick with the kick keeps it low and driven; against it sends it high; centred lobs it; angled to either side curls it — a continuous swerve, unlike a header's fixed 45°
- **On a pass:** with the pass plays it short, the receiver coming to meet it; centred or against plays the default grounded pass to feet; angled with the pass plays it to the receiver's side; angled against plays it beyond them, a through-ball to run onto
- **A lofted kick drives the ball's fake height**, the same system the shadow reads, per [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md)
- **Dead balls use the same kick** — throw-ins, corners, goal kicks and penalties have no input of their own
- **Passing** widens the maximum pass length and the cone a teammate must stand in to count as a target. **Shot Power** sets a shot's raw power and distance. **Finishing** adds power and accuracy inside the box only — never to a header, never from outside it — and feeds the keeper's save chance

*Derived from: Passing, Shooting & Finishing and Controls, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Action Button

From [1.3 Contextual Action](../../../project/milestones/1.3-contextual-action.md).

- **Off the ball, the ball's height at the press decides the action:** 8 or lower slides, above 8 heads. Slide and header are one branch on one button
- **A slide needs the stick held** and the player between 8.5 and 49.5 from the ball. **A header** needs only to be within 49.5 — a dive with the stick held, a jump with it centred. Nothing caps the height a header can be attempted at

## Sliding

From [1.3](../../../project/milestones/1.3-contextual-action.md); against an opponent, [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A fixed lunge, not a fast run.** 175 in the held direction, the same for every player and faster than anyone runs, decaying evenly to a stop over 0.76 and covering about 69. Speed doesn't read it
- **Tap or hold sets its strength.** Released within the slide's first 0.08 it's weak; held past that, strong. The CPU always slides strong
- **Reaching the ball — within 8 at any point in the lunge — takes it, from any angle.** The slider drops to half speed and the ball leaves at 0.75× the slider's speed from a weak slide, 1.25× from a strong one, 1× from the CPU's. The lunge decelerates, so the earlier it connects, the harder the ball goes
- **Holding the stick 45° to either side** when it connects deflects the ball that way. A loose ball takes the slide the same — a bouncing 50/50, a rebound in the box
- **Then the slider lies down.** After a strong slide, by Tackling: 1.20, 1.08, 0.96, 0.84, 0.72, 0.60, 0.48, 0.36 from 0 to 7. After a weak one, 0.12 whatever the skill

*Derived from: Sliding, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Heading

From [1.3](../../../project/milestones/1.3-contextual-action.md); contested at [2.3](../../../project/milestones/2.3-contests.md).

- **A header connects within 8 of the ball while it's between 8 and 15 high, in the first 0.35 of the jump.** Above 15 nothing reaches it; a header started under a higher ball connects if the ball drops into the band in time
- **The dive** — stick held at the press — launches the player at 200 that way. The stick at contact, against the dive's direction, aims it:
  - **With the dive:** low and straight
  - **45° off:** low, deflected 45° toward the stick
  - **90° off:** a flying header, deflected 45°
  - **135° off:** a lob, deflected 45°
  - **Straight back:** a lob, straight
  - **Centred:** a flying header, straight
- **A dive header leaves at 1.25× the diver's speed** — a flying header at 75% of that and rising faster, a lob at 94% and rising fastest
- **The jump** — stick centred at the press — barely moves the player. At contact the ball goes wherever the stick points, behind included, or the way the player faces if it's centred; the player turns up to 90° toward it, for show. It leaves at 175, popping up off the head at half the vertical speed it arrived with. Nothing aims its height
- **Heading sets only how hard a header is struck** — 33 slower at Heading 0, in even steps to no change at 7. Reach and aim read no attribute
- **A jumping player takes the ball's height conventions** — the shadow and the sort-order override, per [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height)

*Derived from: Heading, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Passive Duel

From [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A defender can win the ball just by reaching it**, no button: coming within 5.7 of the ball, stick held, while the opponent's controlled player is within 8.5 of it and moving. The same on a loose ball the opponent is near
- **Each player brings one number: (Tackling + Ball Control) ÷ 2.** The difference between the two is looked up in a probability table, so a player strong in one and weak in the other plays like a balanced player with the same average
- **The winner is safe from another duel for 0.48**, and the ball stops dead

*Derived from: Ball Control, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Fouls

From [2.3 Contests](../../../project/milestones/2.3-contests.md). Detection only — the restart is [5.3](../../../project/milestones/5.3-free-kicks-and-penalties.md)'s, cards and injuries [5.4](../../../project/milestones/5.4-cards-and-injuries.md)'s.

- **When a slide reaches the ball, it's marked clean** if the opponent is neither on the ball (within 3) nor touching the slider (within 5.7); otherwise it's marked as having touched the ball
- **Running into the opponent** — within 5.7, while the slide still moves at 50 or more and the opponent is within 28 of the ball — is checked against that mark:
  - **Ball not yet reached:** a foul, from any angle
  - **Touched:** a foul only from behind — the slider moving the way the opponent faces, within 45°
  - **Clean:** never
- **A keeper is never fouled this way**; the slider drops to a quarter of their speed

*Derived from: Sliding, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Same-Tick Contacts

From [2.3 Contests](../../../project/milestones/2.3-contests.md), where two players first reach the same ball.

- **Contacts are resolved together, after everyone has acted.** Each player's contact with the ball — a pick-up, a strike, a keeper's claim — is judged against the state at the start of the tick, per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Processing order never decides one
- **Possession goes to the passive duel.** When opposing players both meet the pick-up condition on the same tick, the duel settles it, as it does when one closes on the other's ball
- **The ball is struck at most once per tick.** When two slides or two headers reach it together, attributes decide — Tackling between slides, Heading between headers. The stronger player has the advantage, not a certainty, as in the duel

*Departs from SWOS: the reference updates the teams on alternate ticks, so its opponents never reach the ball on the same tick and it has nothing like this section. Rare, and decided with *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md).*

## Acceptance Criteria

- The same intent produces the same movement from keyboard and pad
- The player faces and moves in the stick's new direction on the tick it changes, with the ball and without
- Top speed matches the table at every Speed, and carrying gives exactly 87.5% of it
- The player takes the ball exactly when within 5.7, with the ball at 12 or lower and the stick held, and not otherwise
- The catch-up boost applies exactly while the ball is 90° or more off the carrier's facing
- Running straight, the ball creeps ahead at the table's rate for each Ball Control, within 10%
- A turn made while the ball is out of reach leaves it travelling the old way
- With an opponent within 8.5 of the ball, touch is lost on exactly the held change of direction the table gives at every Ball Control, and not before; without one, never. Centring the stick on the ball resets the count
- Off the ball, the button slides at a ball 8 or lower and heads above 8, by its height at the press
- The slide's lunge is identical at every Speed; release inside the window gives a weak slide and later a strong one, and the ball leaves at the matching multiple of the slider's speed
- Recovery after a slide matches the table at every Tackling
- A header connects exactly within 8 of the ball and between 8 and 15 high; the dive's aim matches its table at every stick position, and the jump sends the ball the stick's way
- The duel's outcome depends only on the two averages and the seed, never on which player closed in
- Each foul case is a foul exactly as listed, and a keeper never is
- Reversing the order players are processed in never changes a tick's outcome for a given seed, and a ball reached by two players on one tick is struck once
- **Judged by playing:** a player can be nudged a few world units to line up with the ball without overshooting, and a resting stick never moves them
- **Judged by playing:** aftertouch always bends the ball relative to the kick — no shot ever goes the way the player didn't push

## Open Questions

- **Confirm the creep rates against the reference.** They are worked from the code, not measured; run swos-port before 1.1 is Ready
- **Not yet in the research:** the duration that splits tap from hold, aftertouch's strength and fade, the kick and pass speeds, the pass cone and length by Passing, and the duel's probability table. Read before 1.2 and 2.3 are Ready
- **How much advantage when two strike on the same tick?** Reusing the passive duel's probability table on the attribute difference is the obvious start. Decide before 2.3 is Ready
- **Mixed pairs** — a slide against a header right at the 8 boundary, or a slide meeting a kick — and which attribute settles them
- **A keeper's claim against a strike on the same tick** — which wins, and on what

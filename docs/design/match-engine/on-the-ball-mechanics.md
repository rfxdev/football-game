# On-the-Ball Mechanics

## At a Glance

- **One stick, one button.** Game code reads a direction and the action, never a device — [Input as Intent](#input-as-intent)
- **Players turn instantly and pass through each other**, contesting each other only through the ball — [Movement](#movement)
- **The ball is taken by running onto it, and runs ahead in touches.** A turn while it's out of reach leaves it behind, and too many turns under pressure lose touch — a good dribbler is better at both — [Carrying the Ball](#carrying-the-ball)
- **On the ball, the button kicks.** Tap passes, hold shoots, and aftertouch shapes either relative to the kick — [Kicking](#kicking)
- **A restart is taken with the same kick, a throw-in included**, facing only back into play — [Taking a Restart](#taking-a-restart)
- **Off the ball, it slides or heads**, picked by the ball's height at the press — [The Action Button](#the-action-button), [Sliding](#sliding), [Heading](#heading)
- **A defender can also win the ball just by reaching it**, settled by attributes — [The Passive Duel](#the-passive-duel)
- **A slide that meets the opponent before the ball is a foul** — [Fouls](#fouls)
- **A tackle that lands may injure**, and an injured player plays on slowed — [Injuries](#injuries)
- **Contacts on the same tick are resolved together**, never by processing order — [Same-Tick Contacts](#same-tick-contacts)

Each section names the milestone that first builds it. Bindings and the pad itself are [Deck Input Parity](../../../ways-of-working/deck-input-parity.md)'s. Speeds are in world units — the reference's pixels, per [Architecture and Stack](../../decisions/architecture-and-stack.md) — per second, and durations in seconds.

## Input as Intent

From [1.1 Movement and Possession](../../../project/milestones/1.1-movement-and-possession.md).

- **The intent delivers the [Player Manual](../../manual/player-manual.md#controls)'s Controls.** The stick, d-pad or arrow keys give the direction; A or Space gives the action
- **Game code reads a per-player intent — a direction and the action — never a device.** One player uses it until two-player mode, which gives each player a pad behind the same seam without touching anything that reads intent
- **The direction is one of eight, or none**, as on the reference's digital joystick. The stick is snapped to the nearest eighth before anything reads it
- **The stick deadzone is a feel value owned here.** It sets how far the stick moves before a direction registers: too large and a small adjustment needs a shove that overshoots, too small and a resting stick drifts. Set per action in the Input Map and tuned on the pad

**Acceptance criteria:**

- The same intent produces the same movement from keyboard and pad
- **Judged by playing:** a player can be nudged a few world units to line up with the ball without overshooting, and a resting stick never moves them

## Movement

From [1.1](../../../project/milestones/1.1-movement-and-possession.md).

- **Speed sets top running speed**, by the table below — about a 35% swing. Carrying is [Carrying the Ball](#carrying-the-ball)'s
- **A step is the speed times the direction's sine and cosine in 128ths, rounding down**, as the ball's, per [Ball Movement](ball-physics-and-aerial-simulation.md#ball-movement) — so straight along an axis a player covers 127/128 of the table's speed
- **Every player faces one of eight directions, part of their state** per *Simulation state* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Rules read it, and a sprite only shows it, per [Sheets](sprites.md#sheets). What sets it:
  - **On the stick, the stick's direction**, on the tick it changes, kept while the stick is centred. That's each side's controlled player, a CPU side's through its intent per [Decision Rate](team-ai-and-decision-making.md#decision-rate). At a restart, the taker gets only the directions [Taking a Restart](#taking-a-restart) allows
  - **Off the stick, the way they run, and the ball when standing** — the restart spot instead while play is stopped, per [Stoppages](match-state-machine.md#stoppages). A keeper faces the ball, running or not, while it's in either penalty area, unless they have it. First met at [2.1](../../../project/milestones/2.1-keeper-drill.md), whose keeper is the first player off the stick
  - **Off the stick, a direction is rounded to the nearest eighth** from the 256 of [Ball Movement](ball-physics-and-aerial-simulation.md#ball-movement), a tie going clockwise. Those are linear within each eighth, so an eighth's edge sits about 26.6° off an axis, not 22.5°
- **Player state also records what each player is doing** — running or standing, sliding, heading, or **down**: on the ground once a slide or a foul is over, until back on their feet. A player who's down is out of the game, passed over by [Carrying the Ball](#carrying-the-ball)'s pressure rule, [The Passive Duel](#the-passive-duel) and [Who Goes for the Ball](team-ai-and-decision-making.md#who-goes-for-the-ball)
- **Turning is instant, on the ball and off it** — on the stick, a player runs the way they face from the tick it moves. No turning circle and no animation to wait out — the reference leans on reflexes, not momentum. No attribute reads it; what turning on the ball costs is [Carrying the Ball](#carrying-the-ball)'s
- **Players aren't solid to each other.** Bodies pass through one another, teammates and opponents alike; players only contest each other through the ball

| Speed | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Running | 91 | 95 | 100 | 104 | 109 | 113 | 118 | 122 |
| Carrying | 79 | 83 | 87 | 91 | 95 | 99 | 103 | 107 |

**Acceptance criteria:**

- The player faces and moves in the stick's new direction on the tick it changes, with the ball and without, and keeps that facing while the stick is centred
- Off the stick, a player faces the eighth they run in, or standing, the eighth towards the ball or the restart spot — exact at every edge and tie
- Running speed matches the table at every Speed

*Derived from: Movement and Engine Performance, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the stick is read every tick, not every other, so a turn lands on the tick the stick moves — per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Players not being solid is decided here; the research doesn't cover bodies meeting.*

## Carrying the Ball

From [1.1](../../../project/milestones/1.1-movement-and-possession.md); the pressure rule is judged at [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A player takes the ball by running onto it** — within 5.7 of it (a squared distance of 32), the ball no higher than 12, the stick held in a direction. With the stick centred they stop, and the ball isn't carried
- **Carrying slows everyone by the same share** — to 87.5% of top speed, the Carrying row in [Movement](#movement)'s table
- **The ball runs ahead in touches.** Carried, it creeps ahead of the carrier until it's out of reach, runs loose for a moment, and is caught again, at the rate in the table below — a poor dribbler is out of reach about every second, a good one every several. The reference gets there by setting the ball to the carrier's speed plus a Ball Control offset on two ticks in four, less a little friction each tick; resetting it every tick, per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md), changes that sum, so the creep is the target and the mechanism is tuned to it
- **A turn while the ball is out of reach leaves it behind.** Only a ball in reach turns with the carrier; a loose one keeps going the old way. This is how a poor dribbler loses the ball with nobody near, and why turning on the ball is a matter of timing. Whether a lost ball reads as the player's mistake or the game's is what [1.1](../../../project/milestones/1.1-movement-and-possession.md) is judging
- **After a turn, the ball swings round to catch up.** While it sits 90° or more off the carrier's facing, it runs a further 25 faster until it's back in front
- **Under pressure, changing direction too often loses touch too.** Each change of direction on the ball counts once the new direction has held for 2 ticks, and centring the stick on the ball resets the count. The hold stands in for the reference reading the stick only every other tick, which let a quick roll past a diagonal go uncounted — whether 2 is enough is judged at 1.1. At the table's count, the carrier loses touch for 0.32 seconds and the ball runs on loose — if any opponent who isn't down is within 8.5 of the ball, sliding and heading included. Unopposed the count climbs without cost, so a player who has weaved freely can meet a challenge already over the limit

| Ball Control | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Creep | 5.6 | 4.9 | 4.2 | 3.5 | 2.8 | 2.2 | 1.5 | 0.8 |
| Changes of direction before touch is lost | 4 | 5 | 6 | 8 | 11 | 14 | 17 | 21 |

**Acceptance criteria:**

- The player takes the ball exactly under the pick-up condition, and not otherwise
- Carrying speed matches the table at every Speed
- Running straight, the ball creeps ahead at the table's rate for each Ball Control, within 10%
- A turn made while the ball is out of reach leaves it travelling the old way
- The catch-up boost applies exactly while the ball is at its angle off the carrier's facing
- With an opponent in range, touch is lost on exactly the held change of direction the table gives at every Ball Control, and not before; without one, or with only opponents who are down, never. Centring the stick on the ball resets the count

*Derived from: Movement and Ball Control, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the creep is held to the reference's rate but reached by a different sum, since the ball is reset every tick rather than every other; and a change of direction counts only once held for 2 ticks, standing in for the reference reading the stick at half the rate. Both follow *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Any opponent on their feet counts as pressure, where the reference reads only their controlled player — decided here, so the rule doesn't depend on who is controlled.*

## Kicking

From [1.2 Kicking](../../../project/milestones/1.2-kicking.md).

- **On the ball, tap passes and hold shoots or lobs.** One button, no modifier
- **Aftertouch is relative to the kick's own direction**, never absolute up or down, and it fades — the sooner the stick moves after the kick, the bigger the effect. It works by moving the point the ball heads for, per [Ball Movement](ball-physics-and-aerial-simulation.md#ball-movement)
- **On a shot:** stick with the kick keeps it low and driven; against it sends it high; centred lobs it; angled to either side curls it — a continuous swerve, unlike a header's fixed 45°
- **On a pass:** with the pass plays it short, the receiver coming to meet it; centred or against plays the default grounded pass to feet; angled with the pass plays it to the receiver's side; angled against plays it beyond them, a through-ball to run onto
- **Shown: a kick has no frame of its own.** The kicker keeps running or standing as the ball leaves, per [Sheets](sprites.md#sheets)
- **A lofted kick drives the ball's fake height**, the same system the shadow reads, per [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md)
- **Passing** widens the maximum pass length and the cone a teammate must stand in to count as a target. **Shot Power** sets a shot's raw power and distance. **Finishing** adds power and accuracy inside the box only — never to a header, never from outside it — and feeds the keeper's save chance

**Acceptance criteria:**

- **Judged by playing:** aftertouch always bends the ball relative to the kick — no shot ever goes the way the player didn't push

*Derived from: Passing, Shooting & Finishing and Controls, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Taking a Restart

From [5.1 Kick-off](../../../project/milestones/5.1-kick-off.md), each restart from the milestone that adds it.

- **The taker uses [Kicking](#kicking)'s scheme**, tap or hold with aftertouch, at every restart — a throw-in included. Dead balls have no input of their own
- **They can only face the directions that send the ball into play**, by the pending restart's kind, per [Stoppages](match-state-machine.md#stoppages):

| Restart | Directions allowed |
| --- | --- |
| Kick-off | The five not facing back — sideways included |
| Throw-in | The five not facing out of the pitch |
| Corner | The three into the pitch |
| Goal kick, the keeper's ball | The five upfield or sideways; a CPU side loses the two sideways |
| Penalty | The three towards goal |
| Free kick | All eight |

- **Shown:** the throw-in has a frame of its own, from [5.2](../../../project/milestones/5.2-out-of-play.md). Every other restart is shown as a kick, with no frame of its own, per [Kicking](#kicking)

**Acceptance criteria:**

- At every restart, the taker faces only the directions listed, from the pad and from the CPU
- **Judged by playing:** a restart never feels like a fight with the stick to point the right way

*Derived from: What Stops Play under Match Flow, and Shooting & Finishing, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Action Button

From [1.3 Contextual Action](../../../project/milestones/1.3-contextual-action.md).

- **Off the ball, the ball's height at the press decides the action:** 8 or lower slides, above 8 heads. Slide and header are one branch on one button
- **A slide needs the stick held** and the player between 8.5 and 49.5 from the ball. **A header** needs only to be within 49.5 — a dive with the stick held, a jump with it centred. Nothing caps the height a header can be attempted at

**Acceptance criteria:**

- The button slides or heads by the ball's height at the press, switching exactly at the threshold

## Sliding

From [1.3](../../../project/milestones/1.3-contextual-action.md); against an opponent, [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A fixed lunge, not a fast run.** 175 in the held direction, the same for every player and faster than anyone runs, decaying evenly to a stop over 0.76 and covering about 69. Speed doesn't read it
- **Tap or hold sets its strength.** Released within the slide's first 0.08 it's weak; held past that, strong. The CPU always slides strong
- **Reaching the ball at any point in the lunge takes it, from any angle** — within 8. The slider drops to half speed and the ball leaves at 0.75× the slider's speed from a weak slide, 1.25× from a strong one, 1× from the CPU's. The lunge decelerates, so the earlier it connects, the harder the ball goes
- **Holding the stick to one side when it connects deflects the ball that way** — 45° either side. A loose ball takes the slide the same — a bouncing 50/50, a rebound in the box
- **Then the slider lies down** — after a strong slide, for the time in the table below. After a weak one, 0.12 whatever the skill

| Tackling | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Down after a strong slide | 1.20 | 1.08 | 0.96 | 0.84 | 0.72 | 0.60 | 0.48 | 0.36 |

**Acceptance criteria:**

- The lunge is identical at every Speed; release inside the window gives a weak slide and later a strong one, and the ball leaves at the matching multiple of the slider's speed
- Recovery after a slide matches the table at every Tackling

*Derived from: Sliding, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Heading

From [1.3](../../../project/milestones/1.3-contextual-action.md); contested at [2.3](../../../project/milestones/2.3-contests.md).

- **A header connects only in a narrow height band, early in the jump** — within 8 of the ball while it's between 8 and 15 high, in the first 0.35. Above 15 nothing reaches it; a header started under a higher ball connects if the ball drops into the band in time
- **The dive** — stick held at the press — launches the player at 200 that way. The stick at contact, against the dive's direction, aims it, by the table below
- **A dive header leaves faster than the diver** — at 1.25× their speed, a flying header at 75% of that and rising faster, a lob at 94% and rising fastest
- **The jump** — stick centred at the press — barely moves the player. At contact the ball goes wherever the stick points, behind included, or the way the player faces if it's centred; the player turns up to 90° toward it, for show. It leaves at 175, popping up off the head at half the vertical speed it arrived with. Nothing aims its height
- **Heading sets only how hard a header is struck** — 33 slower at Heading 0, in even steps to no change at 7. Reach and aim read no attribute
- **Whether a jumping player is drawn at a height isn't researched yet**, per [Ball Physics](ball-physics-and-aerial-simulation.md#open-questions)

| Stick at contact | Header |
| --- | --- |
| With the dive | Low and straight |
| 45° off | Low, deflected 45° toward the stick |
| 90° off | Flying, deflected 45° |
| 135° off | Lob, deflected 45° |
| Straight back | Lob, straight |
| Centred | Flying, straight |

**Acceptance criteria:**

- A header connects exactly within its reach and height band; the dive's aim matches its table at every stick position, and the jump sends the ball the stick's way

*Derived from: Heading, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Passive Duel

From [2.3 Contests](../../../project/milestones/2.3-contests.md).

- **A defender can win the ball just by reaching it**, no button: coming within 5.7 of the ball, stick held, while an opponent who isn't down is within 8.5 of it and moving. The same on a loose ball the opponent is near
- **Every player in contact takes part** — on the challenging side, within 5.7 of the ball; on the side with the ball, within 8.5. Nobody who's down
- **Each side brings its strongest player in contact**, by the average of their Tackling and Ball Control. The difference between the two sides' averages is looked up in a probability table, so a player strong in one and weak in the other plays like a balanced player with the same average
- **Each extra player in contact boosts their side.** The boost is a feel value in the tuning Resource; how it applies is in [Open Questions](#open-questions)
- **The duel settles which side wins, not which player.** The winning side is briefly safe from another duel — for 0.48 — and the ball stops dead for whoever reaches it, per [Carrying the Ball](#carrying-the-ball). So a stronger teammate shields the carrier by winning the duel, and takes the ball only by reaching it first

**Acceptance criteria:**

- The duel's outcome depends only on each side's strongest average, how many each side has in contact, and the seed — never on which player closed in or who is controlled
- A player who's down never takes part

*Derived from: Ball Control, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the reference duels only the two controlled players. Here every player in contact counts — each side's strongest duels, and extra players boost their side — decided here, so the duel doesn't depend on who is controlled. Players aren't solid, so several from a side can be in contact at once; the reference never meets that.*

## Fouls

From [2.3 Contests](../../../project/milestones/2.3-contests.md). Detection only — the restart is [Stoppages](match-state-machine.md#stoppages)' and the card [Cards](match-state-machine.md#cards)', from [5.3](../../../project/milestones/5.3-free-kicks-and-penalties.md) and [5.4](../../../project/milestones/5.4-cards-and-injuries.md); the injury a tackle causes is [Injuries](#injuries)'.

- **When a slide reaches the ball, it's marked clean** if the opponent is neither on the ball (within 3) nor touching the slider (within 5.7); otherwise it's marked as having touched the ball
- **Running into the opponent** — within 5.7, while the slide still moves at 50 or more and the opponent is within 28 of the ball — is checked against that mark:
  - **Ball not yet reached:** a foul, from any angle
  - **Touched:** a foul only from behind — the slider moving the way the opponent faces, within 45°
  - **Clean:** never
- **A keeper is never fouled this way**; the slider drops to a quarter of their speed

**Acceptance criteria:**

- Each foul case is a foul exactly as listed, and a keeper never is

*Derived from: Sliding, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Injuries

From [5.4 Cards and Injuries](../../../project/milestones/5.4-cards-and-injuries.md).

- **An injury is rolled on every tackle that lands**, foul or not, independently of any card. The chance depends on the match length, from [Clock and Periods](match-state-machine.md#clock-and-periods), and both chance and severity shift for a player already carrying a knock — in the tables below
- **A side at its limit of injuries and sendings-off can't be injured**, per [Cards](match-state-machine.md#cards). An injury is reported to the match, which records it and counts it towards the limit
- **An injured player plays on, slowed** — their severity's amount below comes off their running speed, before carrying's 87.5% is taken. Only on a human side; a CPU side's players aren't slowed. Substitutions arrive at [6.2](../../../project/milestones/6.2-team-management.md)
- **How an injured player is shown** is in [Open Questions](#open-questions)

| | 3 min | 5 min | 7 min | 10 min |
| --- | --- | --- | --- | --- |
| Injury per tackle | 18.75% | 10.9% | 7.8% | 5.5% |
| Already carrying a knock | 37.5% | 22.3% | 16.0% | 10.9% |

| Severity | 1 (a knock) | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Weight, of 64 | 42 | 7 | 5 | 4 | 3 | 2 | 1 |
| Already carrying a knock | 14 | 15 | 12 | 9 | 7 | 5 | 2 |
| Running speed lost | 9 | 13 | 16 | 19 | 22 | 25 | 28 |

**Acceptance criteria:**

- The roll matches its tables over many seeded rolls, and never reads the card roll
- With the side at its limit, no injury happens
- An injured player on a human side loses exactly their severity's running speed; one on a CPU side loses none

*Derived from: Fouls, Cards & Injuries under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Same-Tick Contacts

From [2.3 Contests](../../../project/milestones/2.3-contests.md), where two players first reach the same ball.

- **Contacts are resolved together, after everyone has acted.** Each player's contact with the ball — a pick-up, a strike, a keeper's claim — is judged against the simulation state at the start of the tick, per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Processing order never decides one
- **Possession goes to the passive duel.** When opposing players both meet the pick-up condition on the same tick, the duel settles it, as it does when one closes on the other's ball
- **The ball is struck at most once per tick.** When two slides or two headers reach it together, attributes decide — Tackling between slides, Heading between headers. The stronger player has the advantage, not a certainty, as in the duel

**Acceptance criteria:**

- Reversing the order players are processed in never changes a tick's outcome for a given seed, and a ball reached by two players on one tick is struck once

*Departs from SWOS: the reference updates the teams on alternate ticks, so its opponents never reach the ball on the same tick and it has nothing like this section. Rare, and decided with *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md).*

## Open Questions

- **Confirm the creep rates against the reference.** They are worked from the code, not measured; run swos-port before 1.1 is Ready
- **Not yet in the research:** the duration that splits tap from hold, aftertouch's strength and fade, the kick and pass speeds, the pass cone and length by Passing, and the duel's probability table. Read before 1.2 and 2.3 are Ready
- **How does the duel's boost for extra players apply, and how big is it?** A shift in the difference between averages per extra player, or a change to the odds the table gives — original design, with no reference numbers. Decide before [2.3](../../../project/milestones/2.3-contests.md) is Ready; 2.3 is one against one, so it's first judged at [3.1](../../../project/milestones/3.1-dumb-five-a-side.md)
- **How much advantage when two strike on the same tick?** Reusing the passive duel's probability table on the attribute difference is the obvious start. Decide before 2.3 is Ready
- **Mixed pairs** — a slide against a header right at the 8 boundary, or a slide meeting a kick — and which attribute settles them
- **A keeper's claim against a strike on the same tick** — which wins, and on what
- **How an injured player is shown.** The reference's tackled animation is the same with or without an injury, but it has injured-player frames, facing up-right and up-left only, per Sprite Data in [Match Mechanics](../../../sources/swos/match-mechanics.md). When it shows them isn't traced. Read before [5.4](../../../project/milestones/5.4-cards-and-injuries.md) is Ready
- **Does a second injury replace the first, or add to it?** The research says only that a knock shifts the next roll. Read before 5.4 is Ready
- **Do CPU sides stay immune to the injury slowdown?** The reference skips them; 5.4 decides whether to keep that

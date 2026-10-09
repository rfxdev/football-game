# Team AI and Decision Making

## At a Glance

- **The CPU decides every tick, through the same intent a pad gives**, so it plays under exactly the human's rules — [Decision Rate](#decision-rate)
- **Each team sends two players for the ball**, the controlled player and a second, on both human and CPU teams — [Who Goes for the Ball](#who-goes-for-the-ball)
- **Everyone else runs straight to their anchor**, re-targeting in turn — [Off the Ball](#off-the-ball)
- **A CPU team's controlled player runs at the ball, and heads on its height** — [The CPU's Controlled Player](#the-cpus-controlled-player)
- **The second player makes the CPU's tackles, never from behind** — [The CPU's Tackle](#the-cpus-tackle)
- **On the ball, the CPU shoots if it can, and otherwise reacts to the nearest opponent** — [The CPU on the Ball](#the-cpu-on-the-ball), with its aftertouch in [CPU Aftertouch](#cpu-aftertouch)
- **The keeper has rules of its own** — [The Keeper](#the-keeper)

Each section names the milestone that first builds it. A human's controlled player is theirs alone, and nothing here moves it. [2.1](../../../project/milestones/2.1-keeper-drill.md)'s line-holding keeper and [3.1](../../../project/milestones/3.1-dumb-five-a-side.md)'s deliberately dumb players are scaffolding their milestones describe, not this design. Distances are in world units, per [Architecture and Stack](../../decisions/architecture-and-stack.md), and durations in seconds.

## Decision Rate

From [2.1 Keeper Drill](../../../project/milestones/2.1-keeper-drill.md), the first time the CPU plays against the player.

- **The CPU decides every tick**, like everything else, per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md). Who goes for the ball, and the CPU's stick and button, are all decided then
- **A decision reads the match one tick old.** It sees a snapshot of the match as it stood at the start of the previous tick, plus the seeded RNG, and nothing else. So the CPU reacts 0.017–0.033 after something happens — 0.025 on average, close to the reference's 0 to 0.04 at 0.02. The human's stick isn't delayed
- **The same snapshot and seed always give the same decision**, so every rule here can be table-tested without running a match
- **Reaction time is built from that delay and two cycles**: the re-target cycle in [Off the Ball](#off-the-ball), and the chaser's re-aim in [The CPU's Controlled Player](#the-cpus-controlled-player). Too fast reads as psychic, too slow as asleep — the axis [2.1](../../../project/milestones/2.1-keeper-drill.md) first names
- **The CPU plays through the same intent a pad gives** — a direction of eight and the action, per [Input as Intent](on-the-ball-mechanics.md#input-as-intent). So it runs, turns, carries and kicks by exactly the human's rules, and nothing here can make it faster

**Acceptance criteria:**

- The same snapshot and seed give the same decision, whatever order players are processed in
- Nothing a decision reads is newer than the start of the previous tick
- A CPU player's movement and kicks meet every criterion in [On-the-Ball Mechanics](on-the-ball-mechanics.md), with the CPU's intent in place of a pad's

*Derived from: Engine Performance and AI Behavior, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the reference decides for each team on alternate ticks, 25 times a second. Here both teams decide every tick, with the reference's per-decision chances and cycles converted to keep their real-time pace, per [Writing From SWOS](../../../ways-of-working/spec-chain.md#writing-from-swos). Deciding every tick on the current match would let the CPU react up to 0.04 sooner than the reference, so decisions read the match a tick old to bring the timing back. Per *Team updates* in [Architecture and Stack](../../decisions/architecture-and-stack.md).*

## Who Goes for the Ball

From [2.2 Two Attackers](../../../project/milestones/2.2-two-attackers.md), the first time a team has two players.

**Each team sends exactly two players for the ball, human or CPU.** On a human team, this is control switching — there's no switch button.

- **The controlled player is the one nearest the ball**, re-picked every tick:
  - **Strictly the nearest.** A tie keeps whoever is earlier in team order, and there's no hysteresis
  - **Never picked:** the keeper, unless it's playing the ball; the player who kicked, for 1.0 after the kick; anyone sliding, heading, down or injured; and the second player
  - **A player losing control stops where they stand**
- **The second player is the nearest of the rest**, picked the same way, leaving out the controlled player. They run at the ball:
  - **They stand still** when within 57 of the ball, if the controlled player is nearer still and also within 57
  - **Once running, they ignore that rule** until their team's pass state resets. When it resets is in [Open Questions](#open-questions)
- **Each excludes the other, so the pair is stable.** The two can swap which is nearer without control moving. On a CPU team, the second player takes control once their squared distance to the ball is 50 less than the controlled player's, unless the controlled player is within 8.5 of the ball
- **A pass makes its target the second player** until the ball is collected. How they move to meet it is the pass's aftertouch, per [Kicking](on-the-ball-mechanics.md#kicking)
- **Reaching the ball makes the second player the controlled one**, and no new second player is picked for 1.0
- **The controlled player is marked on screen**, for both teams. How the reference marks it is in [Open Questions](#open-questions)

**Acceptance criteria:**

- In open play, at most two players per team are ever going for the ball: the controlled player and the second
- After every tick, the controlled player is the nearest player not excluded, and every exclusion holds exactly
- The second player stands exactly under the stop rule, and otherwise runs at the ball
- **Judged by playing:** control doesn't visibly flap between two players converging on the ball

*Derived from: Controls, and Who Goes for the Ball under AI Behavior, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Off the Ball

From [3.2 Shape and Home Zones](../../../project/milestones/3.2-shape-and-home-zones.md), where anchors arrive.

- **Every other outfield player runs to their anchor**, from [Formation and Shape System](formation-and-shape-system.md#anchors)
- **Each re-targets every 0.44, staggered.** A team's re-targets are spread evenly through that cycle, one player at a time in turn through the team, and between turns each runs to their last target. Each slot belongs to a player: when the keeper's or either chaser's slot comes round, it passes unused. So a player released from going for the ball stands where they stopped until their own slot comes round. So the shape trails a moving ball by up to 0.44, as the reference's did
- **Players run straight at their own speed and stop exactly on arrival.** No acceleration, no easing in, no overshoot. A player standing still faces the ball
- **Only their anchors keep teammates apart.** Bodies pass through each other, per [Movement](on-the-ball-mechanics.md#movement), and nothing pushes teammates apart
- **The debug overlay draws each player's target** beside the shadow formation's anchor marker, with the controlled and second players marked, per [Playtesting](../../../ways-of-working/playtesting.md#debug-visualisation). A target off the anchor for anyone but those two is this doc's bug

**Acceptance criteria:**

- Every player but the two going for the ball is running to, or standing on, the anchor they last re-targeted to
- Each re-targets exactly once per cycle, and no two from one team re-target on the same tick
- A player released from going for the ball stays put until their own slot
- A player reaching their target stops on it, never past it
- **Judged by playing:** the shape's lag behind the ball reads as players reacting, not as players ignoring play

*Derived from: Everyone Else, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the reference re-targets to a tactic position looked up by where the ball will land. Here the target is an anchor that follows the ball where it is, per [Formation and Shape System](formation-and-shape-system.md#the-moving-block).*

## The CPU's Controlled Player

From [3.1 Dumb Five a Side](../../../project/milestones/3.1-dumb-five-a-side.md), where running at the ball is all a CPU player does. The header trigger is from [3.3 Decision Loop](../../../project/milestones/3.3-decision-loop.md).

- **Off the ball, it runs at the ball itself**, not at where a ball in the air will land:
  - **It points the stick the eighth nearest the ball**
  - **It re-aims every tick within 28 of the ball**, and otherwise only every 0.32, holding its last direction between re-aims
  - **With no human playing, it wanders** up to 45° off that line
- **It heads or volleys towards the opponent's end, timed on the ball's height.** It presses the button when it is:
  - **facing** one of the three directions towards the opponent's goal
  - **within 25.5** of the ball
  - **while the ball is** rising through 8–14 or falling through 12–20

  Nothing checks the ball will come within reach, so it sometimes jumps at nothing
- **No defensive heading.** Facing its own goal it never heads. A defender facing upfield clears by the same trigger
- **The header is its only press off the ball.** Sliding is the second player's job, per [The CPU's Tackle](#the-cpus-tackle)

**Acceptance criteria:**

- At every re-aim, the stick points the eighth nearest the ball, and holds between re-aims
- The press fires exactly inside the trigger's facing, reach and height bands
- **Judged by playing:** a header that misses reads as a fair miss, not as stupidity

*Derived from: The CPU's Controlled Player, Off the Ball, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The CPU's Tackle

From [3.3 Decision Loop](../../../project/milestones/3.3-decision-loop.md). The slide itself is [Sliding](on-the-ball-mechanics.md#sliding)'s, always strong for the CPU.

- **The second player slides, not the controlled one.** It slides when all of these hold:
  - the opponent has the ball
  - it is between 8.5 and 14 from the ball
  - the ball is 8 or lower
  - the controlled player isn't nearer the ball
- **Never from behind.** It slides only when the carrier faces more than 45° away from its own facing — exactly the case [Fouls](on-the-ball-mechanics.md#fouls) doesn't count as from behind. It slides in its own facing

**Acceptance criteria:**

- The slide fires exactly under its conditions, and never when the two facings are within 45°
- **Judged by playing:** a CPU tackle never feels cheap, a lunge you couldn't have countered

*Derived from: The CPU's Tackle, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The CPU on the Ball

From [3.3 Decision Loop](../../../project/milestones/3.3-decision-loop.md).

**These rules run whenever the CPU's controlled player is within 8.5 of the ball.** That's a distance check only, so they run with the opponent on the ball too. Distance to goal is measured from the ball to the centre of the goal line it attacks. The first rule that applies wins:

1. **The header trigger**, per [The CPU's Controlled Player](#the-cpus-controlled-player)
2. **Shoot, if close and facing goal.**
   - Within 113 of goal, facing within 21° of it — within 70° once inside 57
   - Between 113 and 170, on 11% of ticks
   - Never while facing sideways with the ball level with the goal area
3. **While a sidestep holds**, pass if a teammate is open, and otherwise keep sidestepping
4. **Within 99 of goal, dribble.** With the ball at its feet — within 5.7 — it turns towards goal; otherwise it keeps its line
5. **Otherwise it reacts to the nearest opponent** — their controlled player if within 71 of the ball, else their second player:
   - **None within 71:** dribble, as in 4
   - **Within 28:** pass if a teammate is open, and otherwise sidestep. More than 424 from goal, it instead hoofs it long if facing goal, or 45° to one side of it, and sidesteps if not
   - **Between 28 and 71:** on 1.5% of ticks, more than 220 from goal, it hoofs it as above. Otherwise it passes or sidesteps through the first quarter of every 0.32, and dribbles the rest of the time
6. **A sidestep** turns 45° off its line with the ball at its feet, and holds for 0.16. One can only start in the first quarter of every 2.56; at other times it dribbles instead

Alongside the rules:

- **A teammate is open when they're the nearest player to the ball within 22.5° either side of the carrier's facing.** Players from either team count, so an opponent in that cone blocks the pass
- **A pass is a tap in the facing direction; a shot or a hoof is a hold.** The pass then finds its target as a human's would, per [Kicking](on-the-ball-mechanics.md#kicking)
- **For 0.6 after any CPU kick, neither CPU team kicks again**
- **The debug overlay names the rule that fired**, so a passage of play can be read back on replay, per [Playtesting](../../../ways-of-working/playtesting.md#debug-visualisation)

**Acceptance criteria:**

- The first rule that applies always wins, each firing exactly under its conditions — a table over goal distance, facing, the nearest opponent and the cone
- **Judged by playing:** a passage of play can be explained rule by rule from the overlay

*Derived from: The CPU on the Ball, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: the reference rolls its chances once a decision, 25 times a second. Here they're rolled every tick at the same rate per second: one decision in four becomes 11% of ticks, and 3.5% becomes 1.5%. Choices it gates on its tick counter keep their real-time cycles. Per [Decision Rate](#decision-rate).*

## CPU Aftertouch

From [3.3 Decision Loop](../../../project/milestones/3.3-decision-loop.md). What each stick position does to the ball is [Kicking](on-the-ball-mechanics.md#kicking)'s.

- **After a shot, it holds the stick at the goal for 0.6** — straight at it, or diagonally inward if the ball is wide of a post
- **Every other kick carries a strength and a curl side.** Through the aftertouch window, it picks afresh every tick, half and half, between two sticks: the strength's, by the table below, or a curl 45°, 90° or 135° off the kick, by strength, towards its curl side
- **A close-range shot** is strength 0, curling towards the far side. **A hoof** is strength 2 beyond 340 from goal, and 1 inside it

| Strength | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Stick | With the kick | Centred | Against the kick |
| Ball | Low and driven | Looped | High |

**Acceptance criteria:**

- On every tick of the window, the stick is either the table's for the kick's strength or its curl angle, each about half the time

*Derived from: CPU Aftertouch, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Keeper

From [2.1 Keeper Drill](../../../project/milestones/2.1-keeper-drill.md), which needs only a placeholder that holds its line. Built at [3.4 Keeper AI](../../../project/milestones/3.4-keeper-ai.md).

**The keeper has no anchor and no role in the pair going for the ball.** Uncontrolled, it follows these rules:

- **Outside its box, it shadows the ball where it is.** It stays inside a small box in front of goal: 103 wide, centred on the goal, from 6 to 32 out from the goal line. The ball's current position across the whole pitch is scaled into that box, so the keeper's position follows the ball the same way the anchors do. It re-targets every 0.32
- **A ball dropping into its box, it goes to where the ball will land** — if it's no more than half as far from the landing point as the ball is. This is a claim, not positioning: no outfield player has one, and the two going for the ball run at the ball itself
- **Within 22 of a ball no higher than 17, it goes to the ball**
- **Otherwise, it often comes out to halfway between the ball and the centre of its goal line**, narrowing the angle. When exactly is in [Open Questions](#open-questions)
- **It goes for a ball 16 or lower if it's nearer to it than all four players going for it**
- **In a one-on-one**, when it's within 11 of the ball as the shooter strikes, the shooter's Finishing against the keeper's skill decides goal or save outright, through a probability table. This is the save chance [Kicking](on-the-ball-mechanics.md#kicking)'s Finishing feeds

**Acceptance criteria:**

- Outside its box, the keeper's target is exactly the ball's position scaled into the box
- **Judged by playing:** the keeper never drifts upfield with play

*Derived from: The Keeper under AI Behavior, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Open Questions

**Research:**

- **Does control flap in play?** The reference has no hysteresis, but the second player's exclusion may hide a flap. Watch two players converge in swos-port before [2.2](../../../project/milestones/2.2-two-attackers.md) is Ready
- **When does the second player stop running?** Once started, they ignore the stop rule until their team's pass state resets, and what resets it isn't fully traced. Watch in swos-port whether they end up beside their own carrier, or hold off. Before 2.2 is Ready
- **How is the controlled player marked?** Read the reference before 2.2 draws it
- **Can the CPU slide from the on-ball rules?** They run on distance alone, so a press there with the opponent on the ball may slide. Read before [3.3](../../../project/milestones/3.3-decision-loop.md) is Ready
- **The keeper's dive, save and speed rules, and the order its rules branch in** — `ShouldGoalkeeperDive` and its skill tables. Read before [3.4](../../../project/milestones/3.4-keeper-ai.md) is Ready
- **How the CPU takes restarts** — throw-ins, free kicks, corners, goal kicks and penalties. Research into `sources/` before [5.1](../../../project/milestones/5.1-kick-off.md) is Ready

**Design:**

- **Does anyone else need to read where a long ball will land?** The reference's outfield shape did, and ours doesn't, per [Formation and Shape System](formation-and-shape-system.md#the-moving-block). If a long ball keeps finding a team out of position, that waits until the clone plays

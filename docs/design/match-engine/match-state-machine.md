# Match State Machine

## At a Glance

- **Play is in, stopped, or waiting on a taker, and the clock runs only in play** — [Play States](#play-states)
- **What stops play decides the restart** — its kind, its spot and which side takes it — [Stoppages](#stoppages)
- **Every restart goes through the same break**: the ball settles, it's placed, players walk to their positions, and the whistle hands it to the taker — [The Break](#the-break)
- **Each restart limits which way the taker can face**, so the ball always goes back into play — [Taking a Restart](#taking-a-restart)
- **A goal leads to a kick-off**, after the scoring side cheers — [Kick-off and Goals](#kick-off-and-goals)
- **A foul may also draw a card, and a tackle an injury**, each rolled on its own — [Cards and Injuries](#cards-and-injuries)
- **The match runs in two halves of game minutes**, each ending only once no attack is on — [Clock and Periods](#clock-and-periods)

Each section names the milestone that first builds it. Until [5.1](../../../project/milestones/5.1-kick-off.md), a ball leaving the pitch resets the scenario, per [0.2](../../../project/milestones/0.2-sandbox-scene.md). Positions are in world units, per [Architecture and Stack](../../decisions/architecture-and-stack.md), speeds in world units a second, and durations in seconds. The pitch's lines are [Pitch and Environment](pitch-and-environment.md)'s; the ball's walls while play is stopped are [Stopped Play](ball-physics-and-aerial-simulation.md#stopped-play)'s; the score and clock on screen are Match HUD's.

## Play States

From [5.1 Kick-off](../../../project/milestones/5.1-kick-off.md).

- **Play is always in one of three states:** in play, stopped, or waiting on the taker. Beside it, the match records which restart is pending, or which stage of the match it's at
- **The clock runs only in play.** A stoppage, the break after it and the wait for the taker all stop it
- **Play moves between them only as below.** Anything else is illegal. What happens while stopped is [The Break](#the-break), or between halves [Clock and Periods](#clock-and-periods)

| From | To | When |
| --- | --- | --- |
| In play | Stopped | A stoppage, or the end of a half |
| Stopped | Waiting on the taker | The whistle, at step 6 of the break |
| Waiting on the taker | In play | The taker's kick or throw |
| Waiting on the taker | Stopped | A CPU side's restart safety net, for a kick-off |

**Acceptance criteria:**

- The transition table, tested as a table: every legal transition taken, every illegal one rejected
- The clock never advances outside play

*Derived from: Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Stoppages

From [5.1](../../../project/milestones/5.1-kick-off.md) for goals; [5.2 Out of Play](../../../project/milestones/5.2-out-of-play.md) for the ball leaving the pitch and the keeper's ball; [5.3 Free Kicks and Penalties](../../../project/milestones/5.3-free-kicks-and-penalties.md) for fouls.

Whatever stops play fixes the restart there and then: its kind, its spot, and the side taking it. Last touch is the last player of either side to play the ball.

| Stoppage | Restart | Taken by | From |
| --- | --- | --- | --- |
| A goal, own goals included | Kick-off | The side that conceded | The centre spot |
| Over a goal line, last touched by the attackers | Goal kick | The defending side | 25 out from the goal line and 60 either side of centre, on the side it went out — (276 or 396, 154 or 744) |
| Over a goal line, last touched by the defenders | Corner | The attacking side | 5 inside both lines, at the corner it went out nearer — (86 or 585, 134 or 764) |
| Over a touchline | Throw-in | The side that didn't touch it last | The touchline, where it crossed |
| A foul on a player inside the fouling side's box | Penalty | The fouled side | The penalty spot, 58 out — (336, 187) or (336, 711) |
| Any other foul | Free kick | The fouled side | Where the fouled player stood |
| The keeper takes the ball | The keeper's ball | The keeper's side | Where it was caught |

- **A foul stops play at once.** No advantage is played, and whether it also draws a card is [Cards and Injuries](#cards-and-injuries)'
- **What is a goal and what is out are [The Goal](pitch-and-environment.md#the-goal)'s** — one predicate on the goal line, read by both
- **A throw-in's third and a free kick's lane are recorded with it.** Which third of the pitch a throw-in is in — split at y 342 and 556 — and, for a free kick within 115 in front of the box, which of seven lanes across the pitch it's in (split at x 153, 261, 309, 362, 410 and 518). The CPU reads both

**Acceptance criteria:**

- Every way out of play maps to exactly the restart, side and spot in the table — tested exhaustively at the lines' edges and fuzzed at awkward ones, per [5.2](../../../project/milestones/5.2-out-of-play.md)
- Every foul gives exactly one penalty or free kick, whether or not it draws a card

*Derived from: What Stops Play under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Break

From [5.1](../../../project/milestones/5.1-kick-off.md), with the kick-off.

Every stoppage runs the same sequence, in order:

1. **Everyone stops where they are**, and the ball runs on until it's still
2. **A pause** — 1.0, or 1.5 after a goal
3. **The ball is put on the restart spot** — except the keeper's ball, already in their hands
4. **Any card is shown**, per [Cards and Injuries](#cards-and-injuries). Then everyone walks to their restart position
5. **Everyone arrives.** The break waits until the referee has gone and every player is in place: all 22 for a kick-off or penalty, otherwise only those in view
6. **The taker is set, and the whistle blows** — except for the keeper's ball. Play then waits on the taker, a human's for as long as it takes
7. **The taker's kick or throw restarts play**, and the clock with it

- **Two safety nets.** If the restarting side still has no taker 10 after the players arrive, the break starts again; and a CPU side that hasn't taken a restart 15 after the whistle gets a kick-off instead. A test that sees either fire has found a soft-lock
- **Where each player stands is in [Open Questions](#open-questions)**, as is who takes each restart

**Acceptance criteria:**

- The steps run in order, and none starts before the one before it has finished
- **No soft-lock:** over fuzzed restarts and seeded matches, play is never stopped longer than a bound set at [5.2](../../../project/milestones/5.2-out-of-play.md), with the taker's input supplied

*Derived from: The Break under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Taking a Restart

From [5.1](../../../project/milestones/5.1-kick-off.md), each restart from the milestone that adds it.

**The taker kicks with [Kicking](on-the-ball-mechanics.md#kicking)'s scheme**, tap or hold with aftertouch, a throw-in included. **They can only face the directions that send the ball into play:**

| Restart | Directions allowed |
| --- | --- |
| Kick-off | The five not facing back — sideways included |
| Throw-in | The five not facing out of the pitch |
| Corner | The three into the pitch |
| Goal kick, the keeper's ball | The five upfield or sideways; a CPU side loses the two sideways |
| Penalty | The three towards goal |
| Free kick | All eight |

- **Shown:** the throw-in has a frame of its own, from [5.2](../../../project/milestones/5.2-out-of-play.md). Every other restart is [Kicking](on-the-ball-mechanics.md#kicking)'s

**Acceptance criteria:**

- At every restart, the taker faces only the directions listed, from the pad and from the CPU
- **Judged by playing:** a restart never feels like a fight with the stick to point the right way

*Derived from: What Stops Play under Match Flow, and Shooting & Finishing, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Kick-off and Goals

From [5.1](../../../project/milestones/5.1-kick-off.md).

- **Kick-off is from the centre spot**, after a goal and at the start of each half
- **Which side kicks off first, and which end each attacks, are drawn separately at random.** Both swap at half-time
- **After a goal, the scoring side cheers where it stopped**, through the pause in [The Break](#the-break). Its outfielders facing up or down the pitch cheer on half of each 1.28-second cycle, staggered by squad order, and the scorer about four-fifths of the time — 2.02 of each 2.56
- **Then everyone walks back at 62.5% of their running speed** until they're in place, with or without the ball

**Acceptance criteria:**

- The side that conceded always kicks off, own goals included
- Over many seeded matches, each side kicks off first and attacks each end about half the time
- **Judged by playing:** a goal gets its moment without the walk back dragging

*Derived from: Match Flow, and Movement, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Cards and Injuries

From [5.4 Cards and Injuries](../../../project/milestones/5.4-cards-and-injuries.md). Foul detection is [Fouls](on-the-ball-mechanics.md#fouls)'.

Three decisions, each independent of the others: the restart, the card, and the injury.

- **Whether a foul draws a card is set per match.** At kick-off a card chance is drawn for the match length, in sixteenths: 4–10 at 3 minutes, 2–6 at 5, 1–4 at 7, 1–3 at 10. A foul draws a card when it falls in the first that-many sixteenths of a 0.64 cycle
- **Which card:** 12.5% red and 87.5% yellow — unless the foul is outside the box with no cover, when it's 87.5% red. No cover means none of the fouler's teammates is nearer the fouled player than the fouled player is to goal
- **A second yellow is a sending-off**
- **An injury is rolled on every tackle that lands**, foul or not. The chance and the severity, and how both shift for a player already carrying a knock, are in the table below
- **An injured player plays on, slowed** — their severity's amount below comes off their running speed, before carrying's 87.5% is taken. Only on a human side; a CPU side's players aren't slowed. Substitutions arrive at [6.2](../../../project/milestones/6.2-team-management.md)
- **Each side has a budget of 4 injuries and dismissals together.** Once it's spent, that side can't be injured or sent off again that match

| | 3 min | 5 min | 7 min | 10 min |
| --- | --- | --- | --- | --- |
| Injury per tackle | 18.75% | 10.9% | 7.8% | 5.5% |
| Already carrying a knock | 37.5% | 22.3% | 16.0% | 10.9% |

| Severity | 1 (a knock) | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Weight, of 64 | 42 | 7 | 5 | 4 | 3 | 2 | 1 |
| Already carrying a knock | 14 | 15 | 12 | 9 | 7 | 5 | 2 |
| Running speed lost | 9 | 13 | 16 | 19 | 22 | 25 | 28 |

**Shown, during step 4 of [The Break](#the-break):**

- **The referee walks on at 100 a second** from just off the edge of the view nearer halfway, to 28 right of and 5 below the foul
- **The booked player walks to 21 right of the foul.** With both there, the referee shows the card and the player's shirt number blinks over them
- **The referee walks off towards the far goal line**, and a sent-off player walks to (−20, 449), off the left touchline at halfway
- **How an injured player is shown** is in [Open Questions](#open-questions)

**Acceptance criteria:**

- Each roll matches its table, over many seeded rolls; the three never read each other
- A second yellow always sends the player off
- With the budget spent, no injury or sending-off happens for that side
- The restart doesn't start until the card has been shown and the referee has gone

*Derived from: Fouls, Cards & Injuries, and Cards on the Pitch under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Clock and Periods

From [5.5 Clock, Halves and Full Time](../../../project/milestones/5.5-clock-halves-and-full-time.md).

- **The clock counts game minutes, from 0 to 90**, and runs only in play
- **Match length is 3, 5, 7 or 10 minutes, 3 by default.** It sets how fast the clock runs: a half lasts 88, 147, 221 or 294 seconds of play. It also sets the card and injury odds above. Picking it is the front end's, once there is one
- **A half doesn't end on the minute.** At 45 and 90 the clock stops, and the half ends once play has run for 1.0 in a row with the ball outside both boxes and last touched by the side defending the half it's in — no restart pending and no attack on. Anything else restarts the count, and nothing caps it, so a corner won at 45 is always taken
- **Half-time:** the whistle, 2.0, the players leave over 5.0, and the score is shown for 14. Ends and kick-off swap
- **Each half starts with the teams coming out**, and the kick-off break begins 2.0 later
- **Full time:** the whistle, 3.0, the players leave over 5.0, and the result is shown for 30
- **The button skips** the half-time score, the result, and the 2.0 before each half's kick-off break
- **The score and anything else that outlives a half survive half-time.** What a finished match reports is [CPU vs CPU simulation](../../README.md#outside-the-match)'s to consume
- **A friendly ends level if it's level.** Extra time and shootouts belong to competitions, and wait for one

**Acceptance criteria:**

- At each match length, a half with no stoppages lasts its seconds of play, to the tick
- A half never ends with the ball in either box, or while the attacking side last touched it
- Every seeded match reaches full time, per [5.5](../../../project/milestones/5.5-clock-halves-and-full-time.md)'s 360 testing

*Derived from: The Clock under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Open Questions

**Research:**

- **Where each player stands at each restart.** The reference uses a second, out-of-play shape and places some players specially at corners and free kicks. Read it before [5.1](../../../project/milestones/5.1-kick-off.md) is Ready, and settle how it maps onto [Formation and Shape System](formation-and-shape-system.md#open-questions)'s grid
- **Who takes each restart.** The restarting side's controlled player, but how it's picked during a break isn't traced. The goal-kick spot is inside the box, which suggests the keeper takes goal kicks. Before 5.1 is Ready
- **The goal-kick box rule.** In the reference, outfielders walking to their positions stop inside the box, widened by 10, until play has restarted and the ball has left it — not yet confirmed whether that reads where they are or where they're stepping. Before [5.2](../../../project/milestones/5.2-out-of-play.md) is Ready
- **How an injured player is shown.** The reference's tackled animation is the same with or without an injury. Before [5.4](../../../project/milestones/5.4-cards-and-injuries.md) is Ready
- **Check the card and budget tables against the Amiga.** Read from DOS only

**Design:**

- **Do CPU sides stay immune to the injury slowdown?** The reference skips them; 5.4 decides whether to keep that

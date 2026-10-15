# Match State Machine

The match's record of what's going on: whether play is live, which restart is pending, the score, the clock and period, cards, injuries, and who kicks off and which way. Other systems report events to it (a goal, the ball going out, a foul, a tackle) and read the state back. None keeps a copy of its own. The record is one part of the simulation state, per [Architecture and Stack](../../decisions/architecture-and-stack.md); each player's state and the ball's belong to the systems that set them. What a system does *during* a state is that system's.

## At a Glance

- **Play is in, stopped, or waiting on a taker, and the clock runs only in play**: [Play States](#play-states)
- **What stops play decides the restart**: its kind, its spot and which side takes it. [Stoppages](#stoppages)
- **Every restart waits through the same break**: the ball settles and is placed, any card is shown, players reach their positions, and the whistle hands it to the taker. [The Break](#the-break)
- **A goal adds to the score and leads to a kick-off**: [Score and Kick-off](#score-and-kick-off)
- **A foul may also draw a card**: [Cards](#cards)
- **The match runs in two halves of game minutes**, each ending only once no attack is on. [Clock and Periods](#clock-and-periods)

Each section names the milestone that first builds it. Until [5.1](../../../project/milestones/5.1-kick-off.md) a goal, and until [5.2](../../../project/milestones/5.2-out-of-play.md) a ball leaving the pitch, resets the scenario, per [0.2](../../../project/milestones/0.2-sandbox-scene.md). Positions are in world units, per [Architecture and Stack](../../decisions/architecture-and-stack.md), speeds in world units a second, and durations in seconds. The pitch's lines are [Pitch and Environment](pitch-and-environment.md)'s; the ball's walls while play is stopped are [Stopped Play](ball-physics-and-aerial-simulation.md#stopped-play)'s; the score and clock on screen are Match HUD's.

## Play States

From [5.1 Kick-off](../../../project/milestones/5.1-kick-off.md).

- **Play is always in one of three states:** in play, stopped, or waiting on the taker. Alongside it, the match records which restart is pending, or which stage of the match it's at
- **The clock runs only in play.** A stoppage, the break after it and the wait for the taker all stop it
- **Anything that halts the match halts the clock**, whatever state play is in. That covers the pause menu and the in-match tactics screen, once they arrive. Neither is a state of play: the match resumes exactly where it stopped
- **Play moves between states only as below.** Anything else is illegal. What happens while stopped is [The Break](#the-break)'s, or between halves [Clock and Periods](#clock-and-periods)'

| From | To | When |
| --- | --- | --- |
| In play | Stopped | A stoppage, or the end of a half |
| Stopped | Waiting on the taker | The whistle, at step 6 of the break |
| Waiting on the taker | In play | The taker's kick or throw |
| Waiting on the taker | Stopped | A CPU side's restart safety net, for a kick-off |

**Acceptance criteria:**

- The transition table, tested as a table: every legal transition taken, every illegal one rejected
- The clock never advances outside play, or while the match is halted

*Derived from: Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Stoppages

From [5.1](../../../project/milestones/5.1-kick-off.md) for goals; [5.2 Out of Play](../../../project/milestones/5.2-out-of-play.md) for the ball leaving the pitch and the keeper's ball; [5.3 Free Kicks and Penalties](../../../project/milestones/5.3-free-kicks-and-penalties.md) for fouls.

Whatever stops play fixes the pending restart there and then: its kind, its spot, and the side taking it. **The match records the last touch**: the last player of either side to play the ball.

| Stoppage | Restart | Taken by | From |
| --- | --- | --- | --- |
| A goal, own goals included | Kick-off | The side that conceded | The centre spot |
| Over a goal line, last touched by the attackers | Goal kick | The defending side | 25 out from the goal line and 60 either side of centre, on the side it went out — (276 or 396, 154 or 744) |
| Over a goal line, last touched by the defenders | Corner | The attacking side | 5 inside both lines, at the corner it went out nearer — (86 or 585, 134 or 764) |
| Over a touchline | Throw-in | The side that didn't touch it last | The touchline, where it crossed |
| A foul on a player inside the fouling side's box | Penalty | The fouled side | The penalty spot, 58 out — (336, 187) or (336, 711) |
| Any other foul | Free kick | The fouled side | Where the fouled player stood |
| The keeper takes the ball | The keeper's ball | The keeper's side | Where it was caught |

- **A foul stops play at once.** No advantage is played. Whether it also draws a card is [Cards](#cards)'
- **What counts as a goal and what counts as out are [The Goal](pitch-and-environment.md#the-goal)'s**: one predicate on the goal line, read by both. What counts as a foul is [Fouls](on-the-ball-mechanics.md#fouls)'
- **A throw-in's third and a free kick's lane are recorded with it.** The third is which third of the pitch a throw-in is in, split at y 342 and 556. The lane applies to a free kick within 115 in front of the box: which of seven lanes across the pitch it's in, split at x 153, 261, 309, 362, 410 and 518. How the CPU uses them is still research, per [Team AI](team-ai-and-decision-making.md#open-questions)
- **The pending restart is what other systems read while play is stopped:** where players stand ([Restarts](formation-and-shape-system.md#restarts)) and which way the taker can face ([Taking a Restart](on-the-ball-mechanics.md#taking-a-restart))

**Acceptance criteria:**

- Every way out of play maps to exactly the restart, side and spot in the table. Tested exhaustively at the lines' edges and fuzzed at awkward ones, per [5.2](../../../project/milestones/5.2-out-of-play.md)
- Every foul gives exactly one penalty or free kick, whether or not it draws a card

*Derived from: What Stops Play under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## The Break

From [5.1](../../../project/milestones/5.1-kick-off.md), with the kick-off.

Every stoppage runs the same sequence of waits, in order:

1. **The ball runs on until it's still**
2. **A pause**: 1.0 second, or 1.5 seconds after a goal
3. **The ball is put on the restart spot**, except for the keeper's ball, which is already in their hands
4. **Any card is shown**, per [Cards](#cards). Then players go to their restart positions
5. **Everyone arrives.** The break waits until the referee has gone and every player is in place: all 22 for a kick-off or penalty, otherwise only those in view
6. **The taker is set, and the whistle blows**, except for the keeper's ball. Play then waits on the taker, a human's for as long as it takes
7. **The taker's kick or throw restarts play**, and the clock with it

- **How players move throughout is [While Play Is Stopped](team-ai-and-decision-making.md#while-play-is-stopped)'s.** Where outfielders stand is [Restarts](formation-and-shape-system.md#restarts)'; the keeper's is still research, in Team AI's [Open Questions](team-ai-and-decision-making.md#open-questions)
- **The taker is the restarting side's controlled player**, per [Who Goes for the Ball](team-ai-and-decision-making.md#who-goes-for-the-ball). How it's picked during a break is research there
- **Two safety nets.** If the restarting side still has no taker 10 seconds after the players arrive, the break starts again. A CPU side that hasn't taken a restart 15 seconds after the whistle gets a kick-off instead. A test that sees either fire has found a soft-lock

**Acceptance criteria:**

- The steps run in order, and none starts before the one before it has finished
- **No soft-lock:** over fuzzed restarts and seeded matches, play is never stopped longer than a bound set at [5.2](../../../project/milestones/5.2-out-of-play.md), with the taker's input supplied

*Derived from: The Break under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Score and Kick-off

From [5.1](../../../project/milestones/5.1-kick-off.md).

- **A goal adds one to the side that scored it.** Which goal the ball went into decides that, so an own goal counts for the other side
- **The match records each goal:** the side, the scorer and the minute. How the reference names the scorer is in [Open Questions](#open-questions)
- **Kick-off is from the centre spot**, after a goal and at the start of each half
- **Which side kicks off first, and which end each attacks, are drawn separately at random.** Both swap at half-time
- **Shown: after a goal, the scoring side cheers where it stopped**, through the pause in [The Break](#the-break). Its outfielders facing up or down the pitch cheer on half of each 1.28-second cycle, staggered by squad order. The scorer cheers about four-fifths of the time, 2.02 seconds of each 2.56

**Acceptance criteria:**

- The side that conceded always kicks off, own goals included
- Every goal adds exactly one, to the side whose opponents' goal it went into
- Over many seeded matches, each side kicks off first and attacks each end about half the time
- **Judged by playing:** a goal gets its moment without the break after it dragging

*Derived from: Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Cards

From [5.4 Cards and Injuries](../../../project/milestones/5.4-cards-and-injuries.md). What counts as a foul is [Fouls](on-the-ball-mechanics.md#fouls)'.

A foul's card is decided on its own: independently of the restart, and of any injury the tackle causes.

- **Whether a foul draws a card is set per match.** At kick-off, a card chance is drawn for the match length, in sixteenths: 4–10 at 3 minutes, 2–6 at 5, 1–4 at 7, 1–3 at 10. A foul draws a card when it falls in the first that-many sixteenths of a 0.64-second cycle
- **Which card:** 12.5% red and 87.5% yellow, unless the foul is outside the box with no cover, when it's 87.5% red. No cover means none of the fouler's teammates is nearer the fouled player than the fouled player is to goal
- **A second yellow is a sending-off.** A sent-off player takes no further part in the match
- **In a friendly, a side has at most 4 injuries and sendings-off together.** After the fourth, that side can't be sent off again that match, or injured, per [Injuries](on-the-ball-mechanics.md#injuries)
- **The match records each player's cards and any injury reported to it**, and each side's count towards that limit

**Shown, during step 4 of [The Break](#the-break):**

- **The referee walks on at 100 a second** from just off the edge of the view nearer halfway, to 28 right of and 5 below the foul
- **The booked player comes to meet them**, per [While Play Is Stopped](team-ai-and-decision-making.md#while-play-is-stopped). With both there, the referee shows the card and the player's shirt number blinks over them
- **The referee walks off towards the far goal line**, and a sent-off player leaves the pitch

**Acceptance criteria:**

- The card roll matches its rules over many seeded rolls, and never reads the restart or the injury roll
- A second yellow always sends the player off
- Once a side reaches the limit, no sending-off or injury happens for it
- The restart doesn't start until the card has been shown and the referee has gone

*Derived from: Fouls, Cards & Injuries, and Cards on the Pitch under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Clock and Periods

From [5.5 Clock, Halves and Full Time](../../../project/milestones/5.5-clock-halves-and-full-time.md).

- **The clock counts game minutes, from 0 to 90**, advancing only as [Play States](#play-states) allows
- **Match length is 3, 5, 7 or 10 minutes, 3 by default.** It sets how fast the clock runs: 45 game minutes take 88, 147, 221 or 294 seconds of play. It also sets the odds in [Cards](#cards) and [Injuries](on-the-ball-mechanics.md#injuries). It's picked on [7.1 Team Select](../../../project/milestones/7.1-team-select.md)'s setup screen
- **A half doesn't end on the minute.** At 45 and 90 the clock stops. The half ends once play has run for 1.0 second in a row with the ball outside both boxes and last touched by the side defending the half it's in: no restart pending and no attack on. Anything else restarts the count, and nothing caps it, so a corner won at 45 is always taken
- **Each half starts with the teams coming out**, and the kick-off break begins 2.0 seconds later. How players come out and leave is [While Play Is Stopped](team-ai-and-decision-making.md#while-play-is-stopped)'s
- **Half-time:** the whistle, 2.0 seconds, the players leave over 5.0 seconds, and the score is shown for 14 seconds. Ends and kick-off swap
- **Full time:** the whistle, 3.0 seconds, the players leave over 5.0 seconds, and the result is shown for 30 seconds
- **The button skips** the half-time score, the result, and the 2.0 seconds before each half's kick-off break
- **Everything the match records survives half-time.** At full time, that record is the match's result: the score, the goals, cards and injuries
- **A friendly ends level if it's level.** Extra time and shootouts belong to competitions, and wait for one

**Acceptance criteria:**

- At each match length, the clock reaches 45 after exactly its seconds of play, to the tick
- **A half ends exactly when its end condition is first met:** at or after 45 or 90, after 1.0 second of play in a row with the ball outside both boxes and last touched by the side defending the half it's in. Never earlier and never later, tested against play that breaks the run at every point
- Every seeded match reaches full time, per [5.5](../../../project/milestones/5.5-clock-halves-and-full-time.md)'s 360 testing

*Derived from: The Clock under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Open Questions

**Research:**

- **How the reference names the scorer.** Who's credited when the ball comes off a defender or the keeper, and how an own goal is recorded. Before [5.1](../../../project/milestones/5.1-kick-off.md) is Ready
- **Check the card table and the limit against the Amiga.** They were read from DOS only. Before [5.4](../../../project/milestones/5.4-cards-and-injuries.md) is Ready
- **Why does the limit count injuries, and how does career set it?** An injured player plays on, so the limit looks aimed at what injuries cost a squad after the match, not at the match itself. The reference works career's limit out from the squad, untraced. Read before [Career](../../../project/ideas/career.md) is scheduled

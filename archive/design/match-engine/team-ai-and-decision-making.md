# Team AI and Decision Making

This doc owns everything an AI-controlled player does: where they move relative to the anchor from [Formation and Shape System](../../../docs/design/match-engine/formation-and-shape-system.md), and what they decide — in attack, what to do with the ball; in defence, when to press and when to tackle. The keeper is covered as a special case.

## Perception and Fairness

The human acts on direct input. AI players act on a **perception snapshot**: a copy of the match state — the ball and players, with positions and velocities — that they read after a delay.

- **The snapshot's age is the reaction delay.** No movement layer or decision reads the live match
- **Too little delay reads as psychic.** The AI reacts to things a person couldn't have seen yet, and the player feels cheated
- **Too much reads as brain-dead.** The AI is always a step behind, and winning feels worthless
- **Reaction delay is a feel constant, not a realism setting** — it lives in the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)
- **Difficulty, if it ever exists, lives here** — in perception delay and decision quality, never in extra speed the player can see

## Movement

Where an AI player moves comes from three layers, slowest-changing first:

1. **Role** — the player's intent: hold shape, press, cover or support
2. **Influence map** — turns that intent into a destination near the player's anchor
3. **Steering** — turns the destination into movement, every frame

- **Every layer reads the perception snapshot**, not the live match
- **Steering, not pathfinding.** The pitch has no static obstacles and every destination keeps moving, so there's nothing for a navmesh to solve
- **Each layer is a pure function of its inputs**, so each can be tested without running a match, per [Automation Testing](../../../ways-of-working/automation-testing.md)
- **One debug overlay covers all three:** each player's role and steering target, drawn beside the formation doc's shadow formation, per [Playtesting](../../../ways-of-working/playtesting.md)

### Roles

A role is the player's current intent. It decides what the influence map looks for; the anchor decides roughly where.

| Role | Intent |
| --- | --- |
| **Hold shape** | Stay near the anchor. The default |
| **Press** | Close down the ball |
| **Cover** | Sit between the ball and goal, behind whoever is pressing |
| **Support** | Give the carrier a pass |

- **The player nearest the ball always presses** when the ball is loose or with the opponents
- **The human-controlled player has no role.** When control switches away, the player picks one up on the next update
- **Transitions use hysteresis.** A player switches into a role at one threshold and back out at a looser one, so a player sitting on the boundary doesn't flip back and forth — which reads as indecisive, worse than either role
- **Breaking shape is tuned between two failures** named at [3.2 Shape and Home Zones](../../../project/milestones/3.2-shape-and-home-zones.md): blobbing, everyone leaving their anchor at once, and bumper cars, nobody ever leaving it. Role thresholds live in the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)

### Influence Map

The influence map is a grid over the pitch. Each cell scores **threat** (how close opponents are), **space** (how open it is) and **ball attraction** (how near the ball it is).

Each player looks at the cells within their **leash** — a radius around their anchor — and picks the best for their role:

| Role | Looks for |
| --- | --- |
| **Hold shape** | The cell nearest the anchor |
| **Press** | The ball, from the goal side |
| **Cover** | Cells between the ball and goal |
| **Support** | Open space away from threat, within reach of a pass |

- **The chosen cell is the steering target.** Off-ball movement that looks intelligent comes mostly from here rather than from rules
- **Resolution and refresh rate are feel constants as much as performance ones.** Too coarse and players drift to the middle of big cells; too fine and they twitch between near-identical scores. Both live in the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)

### Steering

Steering turns the target into movement every frame, combining:

| Behaviour | Does |
| --- | --- |
| **Seek** | Heads for the target |
| **Arrive** | Slows into the target instead of overshooting |
| **Separation** | Pushes nearby teammates apart |

- **Arrive stops jitter.** Without it a player overshoots and circles the target, and jitter reads as broken AI faster than almost anything
- **Separation stops blobbing** at the movement level — a cheap repulsion between teammates
- **AI players move under the same limits as a human-controlled player** — run speed, turning, the cost of carrying the ball — per [On-the-Ball Mechanics](../../../docs/design/match-engine/on-the-ball-mechanics.md)
- **Written by hand, not adopted from tooling** — it's short, and it's the behaviour most in need of tuning
- **Steering weights are feel constants** in the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)

## Decisions

Decisions pick an action, not a place to stand. They follow the movement layers' rules: they read the perception snapshot, and each is a pure function — snapshot in, action out — testable as a table.

**Attacking** — the carrier takes the first that applies:

1. **Pass** if a teammate is open
2. **Shoot** if in range and at an angle
3. **Dribble** goalward — the dribble direction becomes the steering target

- **Coherent beats clever.** The obvious choice every time reads as football; occasional brilliance alongside inexplicable choices reads as broken
- **AI players kick the way the human does** — the same tap and hold, shaped by the same attributes, per [1.2 Kicking](../../../project/milestones/1.2-kicking.md)
- **Range, angle and what counts as "open"** are feel constants in the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)

**Defending** — the presser decides when to slide in rather than rely on the passive duel from running into the carrier. The rule isn't written yet — see Open Questions.

## The Goalkeeper

The keeper isn't in the formation grid and has no role. Its target comes from its own logic instead of the role and influence map; it still reads the perception snapshot and moves through steering.

- **A strong pull back to the goal line** replaces an anchor and leash. Without it the influence map, which knows nothing about the goal line, draws the keeper out of the net
- **First behaviour: move to the ball's projected path.** It doesn't need to be clever to stop the keeper being unmissable
- **Keeper qualities shape it** — positioning, speed of vision, diving speed and range — per [3.4 Keeper AI](../../../project/milestones/3.4-keeper-ai.md)
- **Its decisions aren't written yet:** when to come off the line, when to dive, and what to do once it holds the ball — see Open Questions

## Acceptance Criteria

**Always true:**

- **Someone always presses.** Whenever the ball is loose or with the opponents, at least one player is pressing — the nearest one
- **Same snapshot, same result.** Every movement layer and decision gives the same output for the same inputs
- **Nothing reads the live match.** Every input comes from a snapshot at least the reaction delay old
- **Targets stay inside the leash.** The influence map never picks a cell outside a player's leash
- **AI players never beat the human limits** — run speed, turning, speed with the ball
- **The carrier follows the order.** When more than one option applies, pass beats shoot beats dribble
- **The human-controlled player has no role and no target**

**Feel targets** — intent here, numbers in Open Questions until someone has played it:

- **No dithering.** A player doesn't switch role and back within a short beat
- **Players settle.** Arriving at a target, a player comes to rest without circling or overshooting by more than a small distance
- **Shape breaks and recovers.** A player who stops pressing is heading back towards their anchor within a short beat
- **Fair reaction.** Reaction delay sits in a range that reads neither psychic nor brain-dead
- **The keeper holds its line.** It never strays more than a set distance from the goal line unless a keeper decision sends it for the ball

## Open Questions

**Design:**

- Does perception only delay what an AI player knows, or also limit it — an opponent behind them, say?
- Is reaction delay a single global constant, a per-player stat once squads are differentiated at [6.1 Squads](../../../project/milestones/6.1-squads.md), or the difficulty dial itself?
- Beyond the presser, how are cover and support assigned?
- Does leash distance differ by role — and can the presser reach the ball wherever it is?
- Is there one shared influence map, or one per team, since threat and space aren't symmetric?
- When does a presser slide in — distance, angle, and whether it avoids sliding from behind, where a foul is likely?
- Does the AI use aftertouch?
- When does an AI player head the ball, and what does it aim for?
- When does the keeper come off its line or dive, and what does it do once it holds the ball?

**Numbers for the feel targets:**

- Influence map resolution and refresh rate
- How long a player stays in a role before they can switch back
- How far a player may overshoot their target
- How soon a player who stops pressing heads back
- The reaction delay range
- How far the keeper may stray from the goal line
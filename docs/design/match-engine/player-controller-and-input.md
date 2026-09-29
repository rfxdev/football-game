# Player Controller and Input

movement, acceleration curves, possession states, and what input means to a player. The binding plumbing underneath is [Gamepad Input and Steam Deck Parity](../../../ways-of-working/gamepad-input-and-steam-deck-parity.md)

## Input

- **Game code reads a per-player intent** — a direction and the action — never the device. One player uses it today; two-player mode assigns each player a pad behind the same seam, without touching anything that reads intent
- **Stick deadzone is a movement feel value**, not a hardware default. It decides whether fine positioning feels responsive or twitchy. Where it's set and how it's tuned is [Gamepad Input and Steam Deck Parity](../../../ways-of-working/gamepad-input-and-steam-deck-parity.md)'s

## Turning Radius

- Distinct from acceleration curves: how fast a player can *change direction* at pace, rather than how fast they reach that pace
- A major feel lever, and the usual cause of a player that "handles like a truck" or, at the other extreme, one that pivots unrealistically on the spot
- Likely differs by possession state — turning with the ball should cost more than turning off it, and that difference is much of what makes dribbling feel like a skill rather than a movement mode
- Another feel constant for the tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md)

## Player-vs-Player Collision

- Two player bodies making contact is unowned by any other doc: [Pitch and Environment](pitch-and-environment.md) covers ball-out-of-play boundaries, and [Ball Interaction System](ball-interaction-system.md) covers tackling and loose-ball contention, but neither covers what happens when bodies simply meet
- Needs a decision on whether players are solid to each other at all, and if so whether contact is hard (bodies block) or soft (bodies push through with resistance)
- Interacts with the `separation` steering behaviour in [Team AI and Decision Making](team-ai-and-decision-making.md): separation keeps AI players apart as a *steering* force, before physical collision is ever reached. If separation is working, hard collisions between teammates should be rare, which makes them mostly an opponent-contact concern
- Shoulder-to-shoulder contests for a loose ball sit on the seam between this and the ball interaction system

## Tap vs Hold

- **Tap to pass, hold to shoot or lob**, with hold duration setting power and aftertouch shaping the ball in flight — the reference scheme, per [1.2 Kicking](../../../project/milestones/1.2-kicking.md). One button, no modifier
- The open cost of the scheme is that hold-to-shoot delays the shot by however long the player holds, which is exactly the wrong place to add latency. Whether that reads as *charging* or as *lag* is a feel question, not a design one
- Height needs no input of its own: aftertouch decides it, which settles the ground/lofted distinction in [Ball Interaction System](ball-interaction-system.md)

## Open Questions

- Are players solid to each other, and does that differ for teammates vs opponents?
- Turning with the ball reads Ball Control from [1.1 Movement and Possession](../../../project/milestones/1.1-movement-and-possession.md), per the [Roadmap](../../../project/roadmap.md)'s rule that attributes are wired in with the mechanic. Does turning off the ball read any attribute, or stay one global feel constant?
- In two-player mode, how is a pad assigned to a player — by connection order, or chosen on a join screen? Parked with two-player mode in [Roadmap](../../../project/roadmap.md) → *After Phase 6*

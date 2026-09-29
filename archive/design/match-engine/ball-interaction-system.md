# Ball Interaction System

passing, shooting, tackling, loose ball contention, reach radius logic

## Ground vs Lofted Passing

- "Passing" is really two mechanics with different inputs, different physics, and different tactical uses. Worth naming as two from the start rather than building ground passing and retrofitting height later
- **Ground pass** — stays on the deck, faster to arrive, interceptable along its whole length
- **Lofted pass** — leaves the ground, clears players between passer and target, arrives slower and harder to control on the bounce
- The lofted case is where this doc meets [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md): a lofted pass is the fake-Z height system being driven by a player action, and height-gated collision is what makes it pass *over* an opponent. The two systems have to agree on how height is set and read
- Shooting has the same split — a driven shot along the ground and a lifted one are different actions. All of them share one input: tap/hold decides pass or shot, and aftertouch decides height, per [Player Controller and Input](player-controller-and-input.md)

## Reach Radius and Height

- The reach check is the single gate on whether a player can touch the ball at all, and it has two terms, not one: the ball is within reach radius **and** below head height. A ball overhead is unreachable no matter how close the player is standing
- Keeping the height term inside this one predicate — rather than spread across collision layers or duplicated per action — means every interaction in this doc inherits it for free, and there is exactly one place to look when a player touches a ball they should not have
- The head-height constant is shared with the goal and post gating in [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md) and lives in the tuning Resource with the other feel values
- Jumping is the exception the predicate has to allow for: a player who has left the ground can reach a ball that is above head height, which is the whole basis of heading below

## Ball Contention

Expect this to be the hardest single thing in the match engine, and expect it to feel wrong for a long time before it feels right.

- The difficult case isn't one player reaching the ball — it's **two or three players inside reach radius simultaneously**. Something has to decide, every time, and whatever it decides has to look just to the person holding the controller
- A first-come-first-served check is the obvious implementation and the wrong one: it makes possession a function of frame timing, which is invisible to the player and therefore reads as arbitrary
- Better is an explicit **contest** with weighted inputs — who arrived first, momentum direction (a player running onto the ball beats one standing over it), body position, and a small random factor so identical situations don't always resolve identically
- The random factor is doing real work: perfectly deterministic contests make the game feel solved, and a little noise reads as the bounce of the ball rather than as unfairness — *provided* the other weights dominate. Noise on top of a legible contest feels alive; noise on top of nothing feels rigged
- **Legibility is the acceptance criterion, not correctness.** The player should be able to tell *why* they lost the ball. This is what [3.1 Dumb Five a Side](../../../project/milestones/3.1-dumb-five-a-side.md) exists to stress, with dumb AI guaranteeing constant multi-player pile-ups
- Loose-ball contention and tackling are the same machinery seen from different angles — a tackle is a contest the defender initiates

## Header Contention

- Aerial contests are a **separate mini-system**, not a variant of ground contention: they add height and timing as dimensions, so two players can be in the same place and still not be contesting the same ball
- Depends on both the fake-Z height system in [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md) and on lofted passing existing at all
- The mechanism mirrors the ball's: a jumping player gets **their own height float**, and wins the header contest by being near the peak of that jump when the ball arrives at head height. The fake-Z architecture extends to players without changing, which is the main argument for building it as a general height system rather than a ball-only special case
- Timing is what makes it a distinct skill — the contest is decided by *when* the jump was pressed, not by position, and that is a different thing for the player to be good at than ground contention
- Heading itself lands at [1.3 Contextual Action](../../../project/milestones/1.3-contextual-action.md); contesting it waits for Phase 2 with every other contest. Ground contention needs to feel right first, because heading inherits its contest logic

## Open Questions

- Does the receiving player need a distinct control/trap action for a ball arriving at height, or does the reach radius handle it once the ball is low enough?

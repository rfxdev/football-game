# Ball Physics and Aerial Simulation

2D sprite with fake Z-axis, shadow sprite, height-gated collision, sort-order depth tricks

## The Fake Z-Axis

The ball needs to go over players and over the bar, and the top-down view has no third dimension to put it in. The answer is not to find one: **height is a plain float the ball node owns and updates itself**, sitting alongside its ordinary 2D position. It is not a physics dimension and Godot's physics never sees it.

- Three values carry the whole system — the 2D position the physics already owns, a `height` float where `0.0` is the deck, and a vertical velocity. Each physics frame, gravity is applied to the vertical velocity and the vertical velocity to the height; when height crosses back through zero the ball lands and the vertical velocity flips and is multiplied by a restitution constant, giving the bounce
- **The ball's 2D movement is completely unaffected by its height.** A ball travelling at speed keeps travelling at that speed whether it is rolling or ten feet up. That decoupling is the point: every other 2D system in the match engine keeps running unchanged, and only the systems that specifically care about height ask about it
- The cost of this approach is that it is *entirely manual* — nothing in the engine maintains it, so anything that should respond to height has to be told to. That is a real cost, and it is still cheaper than the alternatives
- It also means this is unusually testable for something that looks like a feel system. Height, gravity, and bounce are arithmetic on a float with no rendering involved, which is exactly why the [Roadmap](../../../project/roadmap.md) puts a GdUnit4 suite over it in groundwork rather than after the first milestone that uses it

## Reading Height Visually

A number the player cannot see is not a mechanic. Two tricks do the work, and both are pure presentation — see [Visual Style Guide](../../../docs/design/visual-style-guide.md) for how they fit the wider look.

- **The shadow.** The ball sprite is drawn at the ball's 2D position and a shadow sprite is drawn at the same position, pinned to the ground layer. As height rises, the shadow shrinks and the *offset* between ball and shadow grows. This is what actually communicates height — the ball alone is ambiguous, ball-plus-shadow is not, and the gap between them reads as altitude instantly and without explanation
- **Sort order.** Top-down 2D fakes perspective by drawing sprites lower on screen in front of ones higher up, which Godot gives free via `y_sort_enabled` on the parent. Above a height threshold the ball overrides that and draws on top of everything — players, goalframe, net. Sorting is what sells *flying over* rather than *passing through*; without it a ball at height looks like a ball clipping through a defender
- These two are why the fake-Z foundation is live from [0.2 Sandbox Scene](../../../project/milestones/0.2-sandbox-scene.md) rather than arriving with lofted passing. A ball that bounces without a shadow reads as broken, and ball feel is being judged from the first moment there is a ball

## Height-Gated Collision

Everything that should be ignorable when the ball is airborne is gated on the same height value. This is the gameplay half of the system and the half that has to be got exactly right, because it decides what the ball can and cannot touch.

- **Players.** Above a head-height constant the ball is out of reach: the reach-radius check in [Ball Interaction System](ball-interaction-system.md) returns false regardless of distance. Gating the interaction logic directly is simpler and more legible than routing it through collision layers, and it keeps the rule in one readable place
- **Goal and posts.** Same gate, applied to scoring and to the post colliders — see [Pitch and Environment](pitch-and-environment.md) for the goal-detection predicate and the disable/re-enable behaviour. Worth keeping here: toggling post colliders mid-frame needs `set_deferred` to stay clear of Godot's physics step
- The head-height and crossbar-height constants are feel values that will be tuned repeatedly, not fixed facts about the world. They belong in the tuning Resource with everything else, and they should be readable by name at every site that gates on them rather than duplicated as literals — a bar that is 1.5 in one file and 1.6 in another is a bug that presents as bad feel

## Ball Motion Model

The fake-Z work above is *presentation* — how a ball at height is drawn and what it can collide with. Separate from that is how the ball actually moves, which is what [0.2 Sandbox Scene](../../../project/milestones/0.2-sandbox-scene.md) establishes and [1.2 Kicking](../../../project/milestones/1.2-kicking.md) puts under pressure:

- **Rolling friction** — how quickly a ball on the ground loses pace. This is the single most felt constant in the game; a ball that runs on forever plays nothing like one that dies under the foot
- **Bounce** — restitution off goalframes, and off the ground when the ball lands from a height. There are no walls: a ball crossing a boundary resets the scenario until Phase 5 gives it a restart, per the [Roadmap](../../../project/roadmap.md). The ground case only exists because of the fake-Z system, so the two are coupled
- **Aerial arc** — how height evolves over a lofted ball's flight, and how horizontal pace and height decay relate. Whether this is real projectile maths or a tuned curve is an open question, and "tuned curve" is a legitimate answer given the "fun over realism" pillar in [Game Vision and Design Goals](../game-vision-and-design-goals.md)

These are feel constants, not implementation details — they belong in a tuning Resource, per [Playtesting](../../../ways-of-working/playtesting.md).

## Tuning Over Defaults

- Godot's 2D physics will carry the mechanics, but the defaults are general-purpose and there is no reason to expect them to produce a good football. Treat every physics value as something to be tuned deliberately rather than inherited
- The concrete levers: `PhysicsMaterial` friction and bounce, `linear_damp`, and — if stock `RigidBody2D` behaviour fights the fake-Z system — custom integration instead
- This is the physics-layer expression of the feel-first approach the whole roadmap is built on: get the ball right before anything is layered on top of it

## Open Questions

- Is aerial flight simulated (gravity, real projectile maths) or authored as a tuned curve?
- Does the ball stay a `RigidBody2D` once fake-Z height is bolted on, or does the height axis force custom integration?
- Does bounce differ by surface — ground, goalframe, player — or is it one restitution value?
- Does the sort-order override flip at a single height threshold, or scale continuously with height? A hard threshold is simpler and may pop visibly on a low bouncing ball
- Does height decay horizontal pace at all, or are the two axes fully independent? Fully independent is the simpler model and probably the right starting point, but a lofted ball that arrives at full speed may play wrong
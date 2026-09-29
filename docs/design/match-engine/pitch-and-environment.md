# Pitch and Environment

pitch dimensions, 5-a-side vs 11-a-side layout, boundary behaviour (ball out of play), visual style of the pitch itself. Could live under Match Engine or be its own child.

## The Goal

The goal is the fiddliest object on the pitch, because it is the one place where the fake-Z height system in [Ball Physics and Aerial Simulation](ball-physics-and-aerial-simulation.md), the 2D collision world, and sprite sorting all have to agree at once.

- **Goal detection is two conditions, and it is simple.** The ball crosses the goal line — a 2D line segment — and its height is below the crossbar. Crossbar height is a constant in the tuning Resource, not modelled geometry. Resist any urge to make this more sophisticated than it is; the complexity in scoring lives in the surrounding match state, not in the test itself
- **Posts are height-gated colliders.** Short collision shapes on the goal line, disabled while the ball is above crossbar height so it can fly over, re-enabled as it drops. A ball that comes down off the underside of the bar is the case that will catch this out
- **The net is layered sprites, not depth.** Front post and bar, middle net, back net, sorted so the ball can be drawn *inside* the net once it crosses the line. It is fakery and it looks correct, which is the standard the top-down view is held to throughout
- Where the goal sits relative to boundary behaviour matters: the goal line and the byline are the same line, so goal detection and ball-out-of-play detection are reading the same crossing event and must not disagree about it. That coupling is a [Match State Machine](match-state-machine.md) concern as much as a geometry one

## Open Questions

- Is the crossbar a single height for the whole goal, or does the top of the net need its own separate value for the sorting trick to look right?
- Do 5-a-side and 11-a-side share goal dimensions, or does the pitch scaling path carry goal size with it?
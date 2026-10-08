# Camera

How much pitch is visible changes whether a pass or a run reads on screen, so it is a design decision, not a configuration one. Pixel scale and sharpness are [Sprites](sprites.md#pixels)'; the settings that deliver both are [Architecture and Stack](../../decisions/architecture-and-stack.md)'s.

## The View

- **The view is about the Amiga's height.** The reference's match screen is 336 × 272 (*Pitch and View* in [Match Mechanics](../../../sources/swos/match-mechanics.md)); the Deck at a scale of 3 shows 426 × 266, 98% of its height. Scale 4 on the Deck was rejected: it inherits DOS's 320 × 200 and loses a quarter of the view up the pitch, the attacking direction
- **No display sees less than the Deck; some see more.** The scale rounds down, never up, so every display sees at least 426 × 266, and up to half as much again where it rounds down furthest. 720p and 768p drop to a scale of 2 and see about a third more height than the Amiga. Still sharp, just smaller sprites; accepted rather than overridden in code
- **Width follows the display from 16:10 to 16:9, then bars** — pillarboxed wider than 16:9, letterboxed narrower than 16:10. Within the band a display sees all its aspect allows: 426 wide on the Deck, 480 at 1080p — both wider than the Amiga's 336, whose picture was nearly 4:3. Sideways scroll is much smaller than the reference's and wide players stay on screen longer; accepted over matching the width with side bars
- **A 16:9 player sees more width than a Deck player** — 13% more at 1080p, half as much again at 720p. Not a fairness problem, since [couch co-op](../game-vision-and-design-goals.md) puts both players on the same screen

## Where It Stops

- **The view stops at fixed positions on the pitch** — x 63 and 609 in open play, 37 and 635 at throw-ins and corners, y 16 and 864, in [Pitch and Environment](pitch-and-environment.md)'s coordinates. They hold on every display; only the reference's internal clamp values, which assume its screen size, don't carry over. How the camera follows play inside them is judged at [3.0 Pitch and Camera](../../../project/milestones/3.0-pitch-and-camera.md)
- **A view wider than the span between the stops is centred on it.** At 720p and 768p the view is wider than open play's 546, so it doesn't scroll sideways at all and shows ground the reference never did
- **The ground is drawn past anything a view can reach.** The [minimum window](../../decisions/architecture-and-stack.md) keeps every view at a scale of 2 or more, and the widest of those is about 708 across, so the ground extends at least 355 either side of the centre spot — beyond the reference's 672-wide map

## Acceptance Criteria

- At every supported display, at every point in the camera's travel, nothing past the edge of the drawn ground is visible
- At the Deck's scale, the run-off on screen at each stop matches the reference's: 18–19 beside each touchline in open play, 44–45 at throw-ins and corners

*Derived from: Pitch and View, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: every display sees wider than the Amiga's 336 — 426 on the Deck — so sideways scroll is smaller, and at 720p and 768p the view doesn't scroll sideways at all. Accepted over side bars, per [The View](#the-view); the height, and where the view stops, match.*

## Open Questions

- **What's beyond the lines?** Grass only, or benches, hoardings and stands — and whether any of it is more than art

# Visual Style Guide

2D sprites
Fake Z-axis for aerial ball (shadow sprite, height-gated collision, sort-order depth tricks)
Top-down perspective

sprite approach, colour palette, camera behaviour, UI/HUD design. Separate from technical architecture since it's design intent rather than implementation.

## Camera

How much pitch is visible changes whether a pass or a run reads on screen, so it is a design decision, not a configuration one. The supported displays, and the settings that deliver this, are [Technical Architecture and Stack](../decisions/architecture-and-stack.md)'s.

- **The visible world is 800 units tall at every supported aspect**, with width floating between 1280 (16:10) and 1422 (16:9). A wider display sees more pitch, not margin
- **A 16:9 player sees about 11% more pitch width than a Deck player, and no extra height.** Not a fairness problem, since [couch co-op](game-vision-and-design-goals.md) puts both players on the same screen
- Built and judged at [3.0 Pitch and Camera](../../project/milestones/3.0-pitch-and-camera.md)

## Showing Height

Height is the one thing a top-down view cannot show directly, and the whole game has aerial play in it. The mechanism — the shadow, and the sort-order override — is owned by [Ball Physics and Aerial Simulation](match-engine/ball-physics-and-aerial-simulation.md); this doc owns what it means for the palette and the art direction.

- **The shadow has to stay legible against every pitch colour the palette settles on.** The player reads altitude from the *gap* between ball and shadow, not from the ball itself, so shadow-versus-ground contrast is a constraint on the palette, not an afterthought to it
- Both conventions extend to jumping players without new invention — the same shadow behaviour, the same sort-order override — since the height system is general rather than ball-specific
- These are cheap effects doing disproportionate work. They belong in the earliest sandbox scene, before any art direction is settled, because ball feel cannot be judged without them

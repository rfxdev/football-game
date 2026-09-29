# Visual Style Guide

2D sprites
Fake Z-axis for aerial ball (shadow sprite, height-gated collision, sort-order depth tricks)
Top-down perspective

sprite approach, colour palette, camera behaviour, UI/HUD design. Separate from technical architecture since it's design intent rather than implementation.

## Camera

The viewport stretches to fill wider displays rather than letterboxing ([Technical Architecture and Stack](../decisions/architecture-and-stack.md)), so a 16:9 window sees further left and right than the Deck does. That is a design problem, not a configuration one: how much pitch is visible changes whether a pass or a run reads on screen.

- **The camera frames a fixed amount of *world*, not a fixed fraction of the screen.** Extra screen space on a wider display becomes margin, not extra pitch — otherwise the same match plays differently on two equally supported displays and neither is wrong
- Worth settling before camera work starts rather than after, since it decides what the camera is scaling against

## Showing Height

Height is the one thing a top-down view cannot show directly, and the whole game has aerial play in it. The mechanism — the shadow, and the sort-order override — is owned by [Ball Physics and Aerial Simulation](match-engine/ball-physics-and-aerial-simulation.md); this doc owns what it means for the palette and the art direction.

- **The shadow has to stay legible against every pitch colour the palette settles on.** The player reads altitude from the *gap* between ball and shadow, not from the ball itself, so shadow-versus-ground contrast is a constraint on the palette, not an afterthought to it
- Both conventions extend to jumping players without new invention — the same shadow behaviour, the same sort-order override — since the height system is general rather than ball-specific
- These are cheap effects doing disproportionate work. They belong in the earliest sandbox scene, before any art direction is settled, because ball feel cannot be judged without them

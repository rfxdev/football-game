# Ball Physics and Aerial Simulation

Fake height, height-gated collision, ball motion, and how height reads on screen.

## Showing Height

A top-down view can't show height directly, and aerial play runs through the whole game. The shadow and the sort-order override carry it; this section covers what they ask of the look.

- **The shadow stays legible against every pitch colour the palette uses.** The player reads height from the gap between ball and shadow, not from the ball, so shadow-against-ground contrast constrains the palette rather than following it
- **Jumping players use the ball's conventions** — the same shadow, the same sort-order override. The height system is general, not ball-specific, so nothing new is invented for them

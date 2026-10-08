# Sprites

The rules every match sprite is drawn to: 2D, viewed from above. What each system's sprites show is that system's doc; the settings that deliver these rules are [Technical Architecture and Stack](../../decisions/architecture-and-stack.md)'s.

## Pixels

- **Pixels are square and sharp on every display.** Each world pixel is a whole number of screen pixels, never a fraction — 3 on the Deck, 4 at 1080p — since pixel art that blurs or shimmers reads as a broken port. How much the [Camera](camera.md) shows at each scale is that doc's
- **The reference's foreshortened ground carries over.** Its pitch markings are drawn at about three-quarters depth and movement is the same pixels on both axes; that is in the world, not the display, so square pixels keep it. Square pixels sit within 4% of the Amiga's shape

*Derived from: Pitch and View, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: pixels are square, where the Amiga's were about 1.04 wide — within 4%, and the foreshortening is in the art, so nothing reads differently.*

## Placeholders

What a fresh clone draws wherever sideloaded art is missing, per [Local Data](../../decisions/licensing-and-ip.md#local-data). Original and committed, so they are also what any published capture shows until the project's own look replaces them.

- **Dimensions and anchor match the sprite they stand in for.** Y-sort and ball contact read the anchor, so a placeholder that differs plays differently. Each is fixed by the milestone that first needs the sprite, per [Roadmap](../../../project/roadmap.md)
- **Flat shapes, not art.** A silhouette in kit colours, with facing shown — a darker back of the head, or a notch on the leading edge
- **One frame per facing, no animation.** Timing is the design's, not the frames', so a still frame changes nothing about play
- **Kit regions are drawn in the reserved colours**, so they recolour like any other sprite's, per [Kits](kits.md#recolouring)
- **Height reads the same.** Placeholders take the shadow and sort-order conventions in [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height) like any other sprite

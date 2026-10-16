# Sprites

Every match sprite is 2D, viewed from above, at a whole-number scale so it stays sharp. Each is cut from a sheet of palette entries that one shader colours, and the match picks its frame; wherever sideloaded art is missing, a fresh clone draws flat placeholders that play exactly like the sprites they stand in for. What each system's sprites show is that system's doc; the settings that deliver these rules are [Technical Architecture and Stack](../../decisions/architecture-and-stack.md)'s.

## Pixels

- **Pixels are square and sharp on every display.** Each world pixel is a whole number of screen pixels, never a fraction — 3 on the Deck, 4 at 1080p — since pixel art that blurs or shimmers reads as a broken port. How much the [Camera](camera.md) shows at each scale is that doc's
- **The reference's foreshortened ground carries over.** Its pitch markings are drawn at about three-quarters depth and movement is the same pixels on both axes; that is in the world, not the display, so square pixels keep it. Square pixels sit within 4% of the Amiga's shape

**Acceptance criteria:**

- A sprite moving at any speed, in any direction, stays sharp — every world pixel the same whole number of screen pixels, no shimmer — at the Deck's scale and 1080p's, judged by eye

*Derived from: Pitch and View, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: pixels are square, where the Amiga's were about 1.04 wide — within 4%, and the foreshortening is in the art, so nothing reads differently.*

## Sheets

How every sprite is stored, whoever drew it — placeholder, sideloaded or the project's own — so swapping art never touches code or timing.

- **Each kind of sprite is one sheet: a grid of equal cells, a row per facing and a column per frame.** A player's facing is one of eight, per [Movement](on-the-ball-mechanics.md#movement). A sprite with no facing, like the ball, has one row
- **The anchor sits at the same point in every cell**, so no frame carries an offset of its own, and Y-sort and ball contact read a point that never moves. Cell size, anchor and frames are fixed in the system's doc alongside the sprite's dimensions, per [Placeholders](#placeholders)
- **A committed description Resource says how to read each sheet** — cell size, anchor, and which cells make which animation. Every art source shares it
- **A pixel is a palette entry, not a colour.** Sheets are 8-bit greyscale, the grey value the entry, 0 transparent. Godot expands an indexed PNG to colour as it loads it, losing the entries, and the reference's palette repeats colours, so they can't be recovered from it
- **Entries mean what the reference's mean** — kit regions, skin and hair shades and the rest — so sideloaded art needs no remapping. Sprite Data and Kits in [Match Mechanics](../../../sources/swos/match-mechanics.md) have them
- **One shader colours every sprite from its palette** — its team's kit and its player's complexion, per [Kits](kits.md#recolouring). The colours are the reference's where its palettes are sideloaded, per [Sideloaded Art](#sideloaded-art), and the project's own otherwise
- **The match picks the frame; the sprite only shows it.** Facing and frame are read from the simulation state each tick, per [Architecture and Stack](../../decisions/architecture-and-stack.md), at the timings the system's doc sets. A sprite runs no animation clock of its own — no `AnimatedSprite2D` playback — so art never sets timing, and drawing never changes play

**Acceptance criteria:**

- Every cell of a sheet draws with its anchor at the sprite's position — exact tests
- The frame shown is a function of the simulation state alone — exact tests

*Derived from: Sprite Data and Kits, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

*Departs from SWOS: each reference sprite has its own size and centre; here a sheet's cells share one, with each frame placed on the anchor, so the same pixels land in the same place.*

## Sideloaded Art

The reference's own sprites and palettes, from a copy the player owns, standing in until the project's look replaces them, per [Local Data](../../decisions/licensing-and-ip.md#local-data). Where `user://` is on each machine is [Build Pipeline](../../../ways-of-working/build-pipeline.md#sideloaded-art)'s.

- **One sheet per kind of sprite in `user://sideload/sprites/`, named and laid out as its description says**, per [Sheets](#sheets). Each reference frame sits in its cell with its centre point on the anchor. The reference's sprite numbers are in Sprite Data in [Match Mechanics](../../../sources/swos/match-mechanics.md)
- **Its palettes in `user://sideload/palettes/`** — the match palette, and the grass for each surface, per [Pitch Conditions](pitch-and-environment.md#pitch-conditions). Each is a one-row image, one pixel per entry in entry order, as the project's own are, named and sized as its committed description says. The match palette is 128 entries — the half of the reference's 256 the match uses, per Sprite Data in [Match Mechanics](../../../sources/swos/match-mechanics.md)
- **The player supplies them.** The project ships no images, palettes or extractor
- **Each sheet falls back on its own.** A sheet that's missing, isn't 8-bit greyscale, or isn't the size its description gives draws the placeholder instead, so a partial set plays exactly like a full one
- **Each palette falls back on its own**, to the project's, if it's missing or the wrong size. Entries mean the same in every source, so any mix of sheets and palettes draws correctly
- **Read once, at startup**

**Acceptance criteria:**

- With nothing sideloaded, every sprite draws its placeholder in the project's colours and play is unchanged
- A sideloaded sheet draws at exactly its placeholder's position, size and layer
- A sheet of the wrong size, or not 8-bit greyscale, is passed over for the placeholder
- A palette of the wrong size is passed over for the project's own

*Derived from: Sprite Data, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Placeholders

What a fresh clone draws wherever sideloaded art is missing, per [Local Data](../../decisions/licensing-and-ip.md#local-data). Original and committed, so they are also what any published capture shows until the project's own look replaces them.

- **Dimensions and anchor match the sprite they stand in for.** Y-sort and ball contact read the anchor, so a placeholder that differs plays differently. Each is fixed in its system's doc when the milestone that first needs the sprite is written, per [Roadmap](../../../project/roadmap.md) — the ball's and shadow's in [Showing Height](ball-physics-and-aerial-simulation.md#showing-height), the outfield player's in [Movement](on-the-ball-mechanics.md#movement)
- **Flat shapes, not art.** A silhouette in kit entries, with facing shown — a darker back of the head, or a notch on the leading edge
- **One frame per facing, no animation.** Every column of a row holds the same frame, so the sheet keeps its description's layout. Timing is the design's, not the frames', so a still frame changes nothing about play
- **Kit regions are drawn in the reserved entries**, so they recolour like any other sprite's, per [Kits](kits.md#recolouring)
- **Height reads the same.** Placeholders are raised and layered per [Ball Physics](ball-physics-and-aerial-simulation.md#showing-height) like any other sprite

## Open Questions

- **How does a sheet hold a sprite drawn for only some facings?** The reference has celebrations facing up and down only, the injured player up-right and up-left, and the booked player down, per Sprite Data in [Match Mechanics](../../../sources/swos/match-mechanics.md) — against a row per facing in [Sheets](#sheets). Decide before [5.1](../../../project/milestones/5.1-kick-off.md) is Ready

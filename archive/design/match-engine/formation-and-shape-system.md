# Formation and Shape System

This doc owns each player's **anchor**: where the formation wants them to stand, built from formations, the moving block and the wide-column rules. What a player does about their anchor belongs to [Team AI and Decision Making](team-ai-and-decision-making.md).

## Formations

- **A formation is a grid layout:** which cells are filled, one player per cell. Nothing else — no team settings, no player instructions
- **Eleven a side is a 5×5 grid plus a keeper.** Rows are position bands within the team's shape — defence, defensive midfield, midfield, attacking midfield, strikers — and columns run left to right. The keeper sits outside the grid
- **Five a side is a 2×2 grid plus a keeper**, holding a 2-2
- **Grid dimensions are data.** Moving from 2×2 to 5×5 will still need code for the extra fidelity
- **Human and CPU teams use the same format.** A CPU club's style is its layout

## The Moving Block

The grid isn't mapped to the pitch one-to-one. It's the team's shape, and it moves around the pitch as a unit.

- **It follows the ball partway.** The block moves a fraction of the ball's movement lengthways, and a smaller fraction sideways, so the team doesn't crowd the ball
- **It squashes at the pitch edges rather than leaving the pitch.** With the ball in a team's own box, the rows compress against the goal line — which is how a team ends up defending deep and compact, with no rule of its own. The same applies at the other goal line and at the touchlines
- **It has a resting size** — a fraction of pitch length and width — and stretches or compresses from there. Fractions let the same layouts work on both pitch sizes
- **Possession nudges it.** The block shifts slightly up when the team has the ball and slightly back when it doesn't. The shift is smoothed so a quickly contested ball doesn't turn players back and forth, a loose ball keeps the last value, and zero switches it off

Follow fractions, resting size, minimum squash spacing, push-up and tuck-in distances, and the possession nudge and its smoothing are feel constants in the tuning Resource — see [Playtesting](../../../ways-of-working/playtesting.md).

## Wide Columns

Players in the two edge columns adjust their anchor to the ball's channel. Every other cell's anchor is just its position in the block.

- **They push up when the ball is in their channel**, on every row — a wide defender overlaps, a wide midfielder gets forward
- **They tuck in when the ball is in the opposite channel**, narrowing the far side towards play
- **In a 2×2 grid both columns are edge columns**, so each player pushes up on their own side and tucks in when play is on the other
- **Position labels come from the cell** — left back, centre midfield — wherever something needs one. They don't change the anchor

## Anchors

A player's anchor is their cell's position in the block, plus any wide-column adjustment. "Home zone" means the same thing.

- **Three inputs decide every anchor:** the layout, the ball's position, and the current possession nudge. Given those, the result is fixed — no timing, and no knowledge of where players actually are
- **Anchors can jump.** A long ball moves every anchor at once; players reach them at run speed, which is Team AI's concern
- **Every outfield player always has an anchor**, including the one the human controls, who ignores it. The keeper has none
- **Team AI decides when and how far a player leaves their anchor** — pressing, supporting, the leash
- **The shadow formation is the debug view:** a marker at every anchor, for either team, drawn alongside the players. A gap between marker and player is Team AI at work; a marker in the wrong place is this system's bug. It sits beside Team AI's role and steering-target overlay, per [Playtesting](../../../ways-of-working/playtesting.md)

## Acceptance Criteria

Everything here is checked against anchors, not against where players actually are.

**Always true**, for any layout, ball position and possession nudge:

- **Every anchor is on the pitch**
- **Squashing never reorders rows or columns.** A compressed block never puts a defender's anchor ahead of a midfielder's, or a left-sided player's to the right of a right-sided one. Wide push-up can — an overlapping wide defender is meant to pass the wide midfielder ahead of them
- **Mirrored inputs give mirrored anchors.** Flip the layout and the ball's position left to right, and every anchor flips with them
- **Pitch size doesn't change the shape.** The same layout and relative ball position give the same anchors, as fractions of the pitch, on either pitch

**Feel targets** — intent here, numbers in Open Questions until someone has played it:

- **Squashed, not stacked.** When the block compresses, anchors stay at least a minimum distance apart, so a deep defence reads as compact rather than a pile
- **The shape doesn't chase the ball.** Wherever the ball is, the anchors alone put only a player or two near it — closing the ball down is Team AI's job
- **A scramble doesn't whip the shape back and forth.** When possession changes, the nudge reaches its new value over a short beat rather than in one update

## Open Questions

**Design:**

- Does sideways follow differ by row, so defenders slide across less than midfielders?
- Is squashing uniform across rows, or does the back row hold while the rows in front close up to it?
- What triggers push-up and tuck-in — how wide is a channel, and does push-up depend on how far up the pitch the ball is?
- Does the block's lengthways follow bring wide players back far enough, or do they need a track-back rule?
- Does the possession nudge earn its place, or does it stay at zero?

**Numbers for the feel targets:**

- The minimum spacing between squashed anchors
- How close to the ball counts as "near", for the player or two whose anchors may sit there
- How long the nudge takes to reach its new value
# Formation and Shape System

A formation is a layout of filled cells on one grid. The grid is the team's shape, a block that follows the ball partway and squashes against the pitch edges, and players in its wide columns shift with the ball's channel. Each outfield player's **anchor** is their cell's place in that block: where the formation wants them to stand. What a player does about their anchor belongs to [Team AI and Decision Making](team-ai-and-decision-making.md).

## Formations

- **A formation is a grid layout:** which cells are filled, one player per cell. Nothing else — no team settings, no player instructions
- **One 5×5 grid for every team size, plus a keeper outside it.** Rows are position bands within the team's shape — defence, defensive midfield, midfield, attacking midfield, strikers — and columns run left to right. The leftmost and rightmost are the **wide columns** — full-backs, wide midfielders, wingers
- **Five-a-side is a 1-2-1 on the same grid** — a defender and a striker in the centre column, two midfielders in the columns either side of it. Compact, with no wide players. Eleven a side adds cells and players, not a grid
- **Human and CPU teams use the same format.** A CPU club's style is its layout
- **Position labels come from the cell** — left back, centre midfield — wherever something needs one. They don't change the anchor

*Departs from SWOS: a SWOS tactic is a hand-placed table of where each player stands for every ball zone, per [Tactics and Team Selection](../../../sources/swos/tactics-and-team-selection.md). Here a layout fixes the shape and the moving block below places it — formations on a grid, per [Game Vision and Design Goals](../game-vision-and-design-goals.md#sensible-world-of-soccer).*

## The Moving Block

The grid isn't mapped to the pitch one-to-one. It's the team's shape, and it moves around the pitch as a unit.

- **It follows the ball partway.** The block moves a fraction of the ball's movement lengthways, and a smaller fraction sideways, so the team doesn't crowd the ball
- **It follows where the ball is, the same for every ball.** The block is the ideal shape for the ball's current position, on the ground or in the air, so it shifts as the ball moves. The keeper's position follows the ball the same way, per [The Keeper](team-ai-and-decision-making.md#the-keeper)
- **It squashes at the pitch edges rather than leaving the pitch.** With the ball in a team's own box, the rows compress against the goal line — which is how a team ends up defending deep and compact, with no rule of its own. The same applies at the other goal line and at the touchlines
- **It has a resting size** and stretches or compresses from there
- **Possession nudges it, without changing the formation.** With the ball the block shifts slightly up and opens out, longer and wider; without it the block shifts back and closes up. The nudge is smoothed so a quickly contested ball doesn't turn players back and forth, a loose ball keeps the last value, and zero switches it off

Follow fractions, resting size, minimum squash spacing, push-up and tuck-in distances, and the possession nudge's shift, resize and smoothing are feel constants in the tuning Resource — see [Playtesting](../../../ways-of-working/playtesting.md).

*Departs from SWOS: SWOS positions players off where a ball in the air will land, and off where a ball on the ground is — [Players Position Off Where the Ball Will Land](../../../sources/swos/tactics-and-team-selection.md#players-position-off-where-the-ball-will-land). Here every ball is followed where it is, so the rule is one rule. The block is ours anyway, per [Formations](#formations).*

## Wide Columns

Players in the two wide columns adjust their anchor to the ball's channel. Every other cell's anchor is just its position in the block.

- **They push up when the ball is in their channel**, on every row — a wide defender overlaps, a wide midfielder gets forward
- **They tuck in when the ball is in the opposite channel**, narrowing the far side towards play

## Anchors

A player's anchor is their cell's position in the block, plus any wide-column adjustment. "Home zone" means the same thing.

- **Three inputs decide every anchor:** the layout, the ball's position, and the current possession nudge. Given those, the result is fixed — no timing, and no knowledge of where players actually are
- **Anchors move with the ball.** A long ball slides every anchor along while it travels; players follow at run speed, which is Team AI's concern
- **Every outfield player always has an anchor**, including the one the human controls, who ignores it. The keeper has none
- **Team AI decides who leaves their anchor** — the two players going for the ball, per [Who Goes for the Ball](team-ai-and-decision-making.md#who-goes-for-the-ball)
- **The shadow formation is the debug view:** a marker at every anchor, for either team, drawn alongside the players. A gap between marker and player is Team AI at work; a marker in the wrong place is this system's bug. It sits beside Team AI's target overlay, per [Off the Ball](team-ai-and-decision-making.md#off-the-ball)
- **The shadow formation also runs in the editor, with no match running.** The whole pitch is in view, with both teams on it; drag the ball and every marker follows. Each team's layout and which team has the ball are set in the Inspector. The switch sets both teams' nudges straight to their values with no smoothing, so one team is always in possession and the other out, as in a match. Running in the editor needs anchors to come from the three inputs alone, which keeps the anchor calculation self-contained

## Acceptance Criteria

Everything here is checked against anchors, not against where players actually are.

**Always true**, for any layout, ball position and possession nudge:

- **Every anchor is on the pitch**
- **The ball's height changes nothing.** A ball in the air gives the same anchors as one on the ground at the same spot
- **Squashing never reorders rows or columns.** A compressed block never puts a defender's anchor ahead of a midfielder's, or a left-sided player's to the right of a right-sided one. Wide push-up can — an overlapping wide defender is meant to pass the wide midfielder ahead of them
- **Mirrored inputs give mirrored anchors.** Flip the layout and the ball's position left to right, and every anchor flips with them

**Feel targets** — intent here, numbers in Open Questions until someone has played it:

- **Squashed, not stacked.** When the block compresses, anchors stay at least a minimum distance apart, so a deep defence reads as compact rather than a pile
- **The shape doesn't chase the ball.** Wherever the ball is, the anchors alone put only a player or two near it — closing the ball down is Team AI's job
- **Open with the ball, compact without it — still one formation.** The difference reads at a glance, but a 4-4-2 never looks like another formation in either phase
- **A scramble doesn't whip the shape back and forth.** When possession changes, the nudge reaches its new value over a short beat rather than in one update

## Open Questions

**Design:**

- Which rows do five-a-side's three lines sit in? Settled by the [3.2](../../../project/milestones/3.2-shape-and-home-zones.md) playtest
- Does sideways follow differ by row, so defenders slide across less than midfielders?
- Is squashing uniform across rows, or does the back row hold while the rows in front close up to it?
- What triggers push-up and tuck-in — how wide is a channel, and does push-up depend on how far up the pitch the ball is?
- Does the block's lengthways follow bring wide players back far enough, or do they need a track-back rule?
- Does the shape trail a fast ball badly enough to need a momentum nudge — the block leaning the way the ball is travelling? Only if it looks wrong at [3.2](../../../project/milestones/3.2-shape-and-home-zones.md)
- **Restarts, for Phase 5 to settle** — research the reference's set pieces into `sources/` first:
  - By default the block follows the dead ball on its restart spot. Is that enough?
  - With the keeper holding the ball or at a goal kick, following the ball crowds the team round its own box. The reference places players as if the ball were on the centre spot, using a separate out-of-play shape
  - At corners and free kicks the reference lines specific players up relative to the restart spot, and the formation places everyone else. Those placements are [Match State Machine](match-state-machine.md#open-questions)'s

**Numbers for the feel targets:**

- The minimum spacing between squashed anchors
- How close to the ball counts as "near", for the player or two whose anchors may sit there
- How far the possession nudge shifts and resizes the block — enough to read, short of looking like another formation
- How long the nudge takes to reach its new value

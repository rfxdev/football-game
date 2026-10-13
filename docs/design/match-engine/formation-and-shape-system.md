# Formation and Shape System

Each outfield player has an **anchor**: where the team's shape wants them to stand. A formation lays the team out on a grid. The grid moves as a block, following the ball partway and squashing against the pitch edges, and players in its wide columns shift with the ball's channel. While play is stopped, the block follows the restart instead of the ball. What a player does about their anchor belongs to [Team AI and Decision Making](team-ai-and-decision-making.md).

## Anchors

A player's anchor is where the formation wants them to stand. "Home zone" means the same thing.

- **Three inputs decide every anchor:** the layout, the ball's position (or, while play is stopped, the pending restart), and the possession nudge. Given those, the result is fixed: no timing, and no knowledge of where players actually are
- **Every outfield player always has an anchor**, including the one the human controls, who ignores it. The keeper has none; their position is [The Keeper](team-ai-and-decision-making.md#the-keeper)'s
- **Team AI decides who leaves their anchor**: the two players going for the ball, per [Who Goes for the Ball](team-ai-and-decision-making.md#who-goes-for-the-ball)
- **The shadow formation is the debug view:** a marker at every anchor, for either team, drawn alongside the players. A gap between a marker and its player is Team AI at work; a marker in the wrong place is this system's bug. It sits beside Team AI's target overlay, per [Off the Ball](team-ai-and-decision-making.md#off-the-ball)
- **The shadow formation also runs in the editor, with no match running.** The whole pitch is in view with both teams on it. Drag the ball and every marker follows. The Inspector sets each team's layout, which team has the ball, and any pending restart. Possession there sets both nudges straight to their values with no smoothing, so one team is always in possession and the other out, as in a match. Running in the editor needs anchors to come from the three inputs alone, which keeps the anchor calculation self-contained

**Acceptance criteria.** Every criterion in this doc is checked against anchors, not against where players actually are, except the goal-kick box rule in [Restarts](#restarts), which checks players. For any layout, ball position, restart and nudge:

- **Every anchor is on the pitch**
- **Mirrored inputs give mirrored anchors.** Flip the layout and the ball's position or restart spot left to right, and every anchor flips with them

## Formations

- **A formation is a grid layout:** which cells are filled, one player per cell. Nothing else: no team settings, no player instructions
- **One 5×5 grid for every team size, plus a keeper outside it.** Rows are position bands within the team's shape (defence, defensive midfield, midfield, attacking midfield, strikers), and columns run left to right. The leftmost and rightmost are the **wide columns**: full-backs, wide midfielders, wingers
- **Five-a-side is a 1-2-1 on the same grid**: a defender and a striker in the centre column, and two midfielders in the columns either side of it. Compact, with no wide players. Eleven a side adds cells and players, not a grid
- **Human and CPU teams use the same format.** A CPU club's style is its layout
- **Position labels come from the cell** (left back, centre midfield) wherever something needs one. They don't change the anchor

**Acceptance criteria:**

- Every layout fills exactly one cell per outfield player, and no cell twice

*Derived from: The Editor Grid, [Tactics and Team Selection](../../../sources/swos/tactics-and-team-selection.md).*

*Departs from SWOS: a SWOS tactic is a hand-placed table of where each player stands for every ball zone. Here a layout fixes the shape and the moving block places it: formations on a grid, per [Game Vision and Design Goals](../game-vision-and-design-goals.md#sensible-world-of-soccer).*

## The Moving Block

The grid isn't mapped to the pitch one-to-one. It's the team's shape, and it moves around the pitch as a unit, except at its wide columns. A cell's anchor is its position in the block.

- **It follows the ball partway.** The block moves a fraction of the ball's movement lengthways, and a smaller fraction sideways, so the team doesn't crowd the ball
- **It follows where the ball is, the same for every ball,** on the ground or in the air. A long ball slides every anchor along while it travels, and players follow at their own speed, per [Off the Ball](team-ai-and-decision-making.md#off-the-ball). The keeper's position follows the ball the same way, per [The Keeper](team-ai-and-decision-making.md#the-keeper). While play is stopped, the restart takes the ball's place, per [Restarts](#restarts)
- **It squashes at the pitch edges rather than leaving the pitch.** With the ball in a team's own box, the rows compress against the goal line. That's how a team ends up defending deep and compact, with no rule of its own. The same applies at the other goal line and at the touchlines
- **It has a resting size** and stretches or compresses from there
- **Players in the wide columns shift with the ball's channel**, on every row. **They push up when the ball is in their channel:** a wide defender overlaps, a wide midfielder gets forward. **They tuck in when it's in the opposite channel**, narrowing the far side towards play
- **Possession nudges it, without changing the formation.** With the ball, the block shifts slightly up and opens out, longer and wider. Without it, the block shifts back and closes up. The nudge is smoothed so a quickly contested ball doesn't turn players back and forth. A loose ball keeps the last value, and zero switches it off

Follow fractions, resting size, minimum squash spacing, push-up and tuck-in distances, and the possession nudge's shift, resize and smoothing are feel constants in the tuning Resource. See [Playtesting](../../../ways-of-working/playtesting.md).

**Acceptance criteria:**

- **The ball's height changes nothing.** A ball in the air gives the same anchors as one on the ground at the same spot
- **Squashing never reorders rows or columns.** A compressed block never puts a defender's anchor ahead of a midfielder's, or a left-sided player's to the right of a right-sided one. Wide push-up can: an overlapping wide defender is meant to pass the wide midfielder ahead of them

**Feel targets.** The intent is here; the numbers stay in [Open Questions](#open-questions) until someone has played it:

- **Squashed, not stacked.** When the block compresses, anchors stay at least a minimum distance apart, so a deep defence reads as compact rather than a pile
- **The shape doesn't chase the ball.** Wherever the ball is, the anchors alone put only a player or two near it. Closing the ball down is Team AI's job
- **Open with the ball, compact without it, but still one formation.** The difference reads at a glance, but a 4-4-2 never looks like another formation in either phase
- **A scramble doesn't whip the shape back and forth.** When possession changes, the nudge reaches its new value over a short beat rather than in one update

*Departs from SWOS: SWOS positions players off where a ball in the air will land. Here every ball is followed where it is, per [Players Position Off Where the Ball Will Land](../../../sources/swos/tactics-and-team-selection.md#players-position-off-where-the-ball-will-land).*

## Restarts

While play is stopped, from the stoppage to the taker's kick, the block follows the restart instead of the ball. *When* players walk to their anchors is [The Break](match-state-machine.md#the-break)'s.

| Restart | The block follows |
| --- | --- |
| Kick-off, throw-in, corner, free kick, penalty | The restart spot |
| Goal kick, the keeper's ball | The centre spot |

- **At a goal kick, no outfielder moves into or within either box, widened by 10,** until play has restarted and the ball has left both. A player already inside stops where they are; one walking towards a box stops at its edge

**Acceptance criteria:**

- **While play is stopped, moving the ball changes no anchor.** The anchors are exactly those the point in the table gives
- **At a goal kick, no outfielder moves into or within either widened box** before the ball has left both

*Derived from: Players Position Off Where the Ball Will Land, [Tactics and Team Selection](../../../sources/swos/tactics-and-team-selection.md), and The Break under Match Flow, [Match Mechanics](../../../sources/swos/match-mechanics.md).*

## Open Questions

**Research:**

- **Kick-off: does anything keep each side in its own half?** A block centred on the centre spot, with the possession nudge, could put attackers over halfway. Read the reference before [5.1](../../../project/milestones/5.1-kick-off.md) is Ready
- **What the reference's out-of-play tactics look like.** Each tactic swaps to its own one at a goal kick or the keeper's ball. Before [5.2](../../../project/milestones/5.2-out-of-play.md) is Ready
- **The goal-kick box rule: the player's position or their next step?** Not yet confirmed which one the reference checks. Before 5.2 is Ready
- **Special placements at corners, free kicks and penalties.** The reference lines specific players up relative to the restart spot, and the formation places everyone else. Before 5.2 for corners, and before [5.3](../../../project/milestones/5.3-free-kicks-and-penalties.md) for free kicks and penalties

**Design:**

- **Which side's nudge applies while play is stopped?** The restarting side's as if in possession, or the last value kept, as for a loose ball. Before 5.1 is Ready
- **Is the out-of-play shape a separate layout on our grid**, or the same layout with the block at the centre spot? Once the research above says what the reference's look like
- Which rows do five-a-side's three lines sit in? Settled by the [3.2](../../../project/milestones/3.2-shape-and-home-zones.md) playtest
- Does sideways follow differ by row, so defenders slide across less than midfielders?
- Is squashing uniform across rows, or does the back row hold while the rows in front close up to it?
- What triggers push-up and tuck-in? How wide is a channel, and does push-up depend on how far up the pitch the ball is?
- Does the block's lengthways follow bring wide players back far enough, or do they need a track-back rule?
- Does the shape trail a fast ball badly enough to need a momentum nudge, with the block leaning the way the ball is travelling? Only if it looks wrong at 3.2

**Numbers for the feel targets:**

- The minimum spacing between squashed anchors
- How close to the ball counts as "near", for the player or two whose anchors may sit there
- How far the possession nudge shifts and resizes the block: enough to read, short of looking like another formation
- How long the nudge takes to reach its new value

# SWOS Player Ratings

Player attribute definitions, scale, and the big-picture gameplay effect of each. For the detail of how a specific mechanic uses these attributes, see [Match Mechanics](match-mechanics.md).

## Outfield Skills

Outfield players are rated on 7 core skills, stored **0–7** on disk; the engine adds a fixed **+8** before using the value in gameplay, so the range that actually drives performance is **8–15**.

| Code | Skill | Gameplay Impact |
| --- | --- | --- |
| **S** | Speed | How fast the player runs. By far the most crucial stat in SWOS. |
| **V** | Shot Power | The raw power and distance of a shot. |
| **F** | Finishing | Modifies shot accuracy and triggers a powerful shot multiplier inside the penalty box. |
| **C** | Ball Control | Governs how well a carrier keeps the ball under close control. |
| **P** | Passing | Increases the speed and pinpoint accuracy of grounded passes. |
| **T** | Tackling | Improves the odds of winning a passive challenge against a carrier and shortens recovery time after any tackle attempt. |
| **H** | Heading | Increases aerial reach and redirection accuracy during cross-balls. |

## Squad Screen Shows Each Player's Top 3 Skills

Alongside every player on the squad screen, SWOS displays their three most prominent skills in descending order as a three-letter code using the codes above (e.g. a code of `VCS` reads as Shot Power, then Ball Control, then Speed — that player's three strongest skills, ranked). It's a compressed readout of the same 7 underlying skill values above, not a separate rating system.

## Positional Effects

Playing someone out of position measurably changes their effective in-match skills while they're there — it's a real-time shift, not just a suitability label.

## Goalkeepers

Keeper quality is modified by a separate set of qualities from the outfield skills above: positioning, speed of vision, and diving speed and range, all of which improve as the keeper's value increases.

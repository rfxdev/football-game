# FM Player Attributes

The current Football Manager rating model. Written from memory and community knowledge rather than a checked source, so treat details as provisional.

## Visible Attributes

All on a **1–20** scale.

- **Technical** — Corners, Crossing, Dribbling, Finishing, First Touch, Free Kick Taking, Heading, Long Shots, Long Throws, Marking, Passing, Penalty Taking, Tackling, Technique
- **Mental** — Aggression, Anticipation, Bravery, Composure, Concentration, Decisions, Determination, Flair, Leadership, Off the Ball, Positioning, Teamwork, Vision, Work Rate
- **Physical** — Acceleration, Agility, Balance, Jumping Reach, Natural Fitness, Pace, Stamina, Strength
- **Goalkeeping** (replaces Technical for keepers) — Aerial Reach, Command of Area, Communication, Eccentricity, First Touch, Handling, Kicking, One on Ones, Passing, Punching (Tendency), Reflexes, Rushing Out (Tendency), Throwing

## Hidden Attributes

Also 1–20, never shown as numbers. The player infers them from reports.

- **Playing** — Consistency, Dirtiness, Important Matches, Injury Proneness, Versatility
- **Personality** — Adaptability, Ambition, Controversy, Loyalty, Pressure, Professionalism, Sportsmanship, Temperament

## Ability and Progression

- **Current Ability (CA) and Potential Ability (PA)**, hidden, on a 1–200 scale. CA is a budget the visible attributes are spent from, and each attribute costs a different amount depending on position.
- **Development moves CA toward PA**, and age moves it back down. The visible attributes follow.
- **Open question:** how strictly the budget binds — whether raising one attribute forces others down.

## Summary Layers

How FM keeps ~50 numbers a quick read:

- **Star ratings** from coaches for current and potential ability
- **Role suitability**, which weights attributes per role and duty
- **Player traits** (formerly Preferred Moves) — named habits, such as "tries to beat offside trap", layered on top of the numbers

## For Us

Grouped by who an attribute would affect in a single-button arcade match:

- **The player you control** — changes feel, as SWOS's Ball Control does. First Touch, Technique, Flair, Balance
- **The 21 you don't** — changes AI behaviour without touching input. Positioning, Off the Ball, Decisions, Anticipation, Work Rate, Teamwork
- **Off the pitch only** — matters only with a career mode. Determination, the personality set, CA/PA
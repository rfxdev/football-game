# FM Player Attributes

The Football Manager rating model.

Attribute names below are written from memory and community knowledge rather than a checked source — treat even the lists as provisional, and check them against the FM version we care about.

**The tables are a deliberately unfilled scaffold.** A dash means *not yet checked*, not *no effect*. Fill a cell only from a source, in our own words per [Sources](../README.md).

All attributes sit on a **1–20** scale. Each is read through three lenses:

- **Offensive** — what it does when the player's team has the ball
- **Defensive** — what it does when it doesn't
- **Meta** — what it does outside the ball-in-play loop

## Technical

| Attribute | Offensive | Defensive | Meta |
| --- | --- | --- | --- |
| Corners | — | — | — |
| Crossing | — | — | — |
| Dribbling | — | — | — |
| Finishing | — | — | — |
| First Touch | — | — | — |
| Free Kick Taking | — | — | — |
| Heading | — | — | — |
| Long Shots | — | — | — |
| Long Throws | — | — | — |
| Marking | — | — | — |
| Passing | — | — | — |
| Penalty Taking | — | — | — |
| Tackling | — | — | — |
| Technique | — | — | — |

## Mental

| Attribute | Offensive | Defensive | Meta |
| --- | --- | --- | --- |
| Aggression | — | — | — |
| Anticipation | — | — | — |
| Bravery | — | — | — |
| Composure | — | — | — |
| Concentration | — | — | — |
| Decisions | — | — | — |
| Determination | — | — | — |
| Flair | — | — | — |
| Leadership | — | — | — |
| Off the Ball | — | — | — |
| Positioning | — | — | — |
| Teamwork | — | — | — |
| Vision | — | — | — |
| Work Rate | — | — | — |

## Physical

| Attribute | Offensive | Defensive | Meta |
| --- | --- | --- | --- |
| Acceleration | — | — | — |
| Agility | — | — | — |
| Balance | — | — | — |
| Jumping Reach | — | — | — |
| Natural Fitness | — | — | — |
| Pace | — | — | — |
| Stamina | — | — | — |
| Strength | — | — | — |

## Goalkeeping

Replaces Technical for keepers. Offensive here means distribution.

| Attribute | Offensive | Defensive | Meta |
| --- | --- | --- | --- |
| Aerial Reach | — | — | — |
| Command of Area | — | — | — |
| Communication | — | — | — |
| Eccentricity | — | — | — |
| First Touch | — | — | — |
| Handling | — | — | — |
| Kicking | — | — | — |
| One on Ones | — | — | — |
| Passing | — | — | — |
| Punching (Tendency) | — | — | — |
| Reflexes | — | — | — |
| Rushing Out (Tendency) | — | — | — |
| Throwing | — | — | — |

## Hidden Attributes

Also 1–20, never shown as numbers. The player infers them from reports.

| Attribute | Group | Offensive | Defensive | Meta |
| --- | --- | --- | --- | --- |
| Consistency | Playing | — | — | — |
| Dirtiness | Playing | — | — | — |
| Important Matches | Playing | — | — | — |
| Injury Proneness | Playing | — | — | — |
| Versatility | Playing | — | — | — |
| Adaptability | Personality | — | — | — |
| Ambition | Personality | — | — | — |
| Controversy | Personality | — | — | — |
| Loyalty | Personality | — | — | — |
| Pressure | Personality | — | — | — |
| Professionalism | Personality | — | — | — |
| Sportsmanship | Personality | — | — | — |
| Temperament | Personality | — | — | — |

## Ability and Progression

- **Current Ability (CA) and Potential Ability (PA)**, hidden, on a 1–200 scale. CA is a budget the visible attributes are spent from, and each attribute costs a different amount depending on position.
- **Development moves CA toward PA**, and age moves it back down. The visible attributes follow.
- **Open question:** how strictly the budget binds — whether raising one attribute forces others down.

## Summary Layers

How FM keeps the whole set a quick read:

- **Star ratings** from coaches for current and potential ability
- **Role suitability**, which weights attributes per role and duty
- **Player traits** (formerly Preferred Moves) — named habits, such as "tries to beat offside trap", layered on top of the numbers
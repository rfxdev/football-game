# Game Vision and Design Goals

The pitch is in the [README](../../README.md). This doc is what that pitch commits to: who the game is for, where its boundaries sit, and the pillars a proposal gets checked against.

## Target Audience & Player Experience

The game targets three overlapping audiences: players with nostalgia for classic 90s football games like SWOS, casual football fans put off by the simulation complexity of modern titles, and indie/retro game fans drawn to the aesthetic and simplicity of the genre.

The core experience is immediate and playful — easy to pick up with single-button input, but with enough depth to reward mastery. The tone is light and fun, in the spirit of SWOS's tiny sprites and daft celebrations.

Couch co-op multiplayer is a priority alongside the core single-player vs CPU experience.

Career mode is future scope and undecided in shape, partly inspired by discovering Championship Soccer. The aim is for it to be genuinely tough rather than guaranteeing the player's success — for example, in a single-player career, underperforming could mean losing your starting place and ending up on the bench. Procedural generation is under consideration as a possible way to sidestep the need for licensed teams and players, not as a confirmed roguelike design direction.

## Scope & Boundaries

**Match-first** (see Design Pillars below) rules out management-sim depth as a parallel system: features like transfers will exist, but framed as part of the meta-narrative around match play rather than management simulation for its own sake.

Player attributes are limited to those that meaningfully affect match engine behaviour — there's no intent to model exhaustive real-world player statistics.

The game is non-profit and open source. As a result, it will not feature licensed teams, players, leagues, or kits — any resemblance to real-world football will be through original or procedurally generated content. [Licensing and IP](../decisions/licensing-and-ip.md) covers why that constraint exists and what it rules in and out, including how the project relates to the published games it takes inspiration from.

Online multiplayer and mobile platforms are not a current focus. The target platforms are Windows, macOS, and Steam Deck (Linux), with local couch co-op as the multiplayer model.

## Design Pillars

- Fun over realism — mechanics and tuning favour what feels good over simulation accuracy.
- Easy to pick up, difficult to master — simple, single-button input; depth comes from execution and decision-making, not control complexity.
- Match-first — every system exists to support the experience of playing matches.
- Failure is meaningful — the game does not guarantee the player's success; setbacks are part of the experience, not something to be designed away.

## Inspirations & References

- Sensible World of Soccer — the primary inspiration for tone, pace, top-down perspective, and single-button simplicity.
- Championship Soccer — inspiration for the career mode direction, particularly its depth of career simulation and the idea that success isn't guaranteed.
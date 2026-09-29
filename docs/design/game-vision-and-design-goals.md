# Game Vision and Design Goals

The top of the constraint chain: what the game is and what it's for. Everything downstream is checked against it, the pillars first.

## The Game

Arcade football inside a football career. The matches are played — top-down, fast, one button — and the career around them gives each one its stakes. Each half feeds the other: a signing made in the career is a player on the pitch, and a result on the pitch changes what the career can do next.

- **The match is played, not simulated.** Who's on the ball changes how you play it
- **The career gives matches their stakes.** Squad, transfers, finances, keeping the job
- **Depth comes from the players, not the controls.** A richer attribute model than the genre's classics, with ability that rises and falls across a career
- **Player-manager or manager.** Pick the team and control it on the pitch, or pick it and direct from the touchline. If the player model is deep enough, a match is as interesting to direct as to play

## Target Audience & Player Experience

Three overlapping audiences: players with nostalgia for 90s football games, casual football fans put off by the simulation complexity of modern titles, and indie/retro fans drawn to the aesthetic and simplicity of the genre.

The experience is immediate and playful — easy to pick up, with enough depth to reward mastery. The tone is light: tiny sprites and daft celebrations.

## Scope & Boundaries

- **Career systems can go as deep as a management sim's, as long as they feed the match.** Transfers, finances and job security all earn their depth by changing the matches you play. None becomes a game in its own right
- **Depth arrives one dimension at a time, level across the systems it interlocks with.** Each system starts at its competent default. A layer ships with its mirror, such as buying with selling, and with just enough depth in the systems it touches to cope
- **Every attribute earns its place in the match engine.** No modelling real-world statistics for their own sake
- **Local couch co-op is in scope alongside single-player.** Online multiplayer and mobile are out

## Design Pillars

- **Fun over realism** — mechanics and tuning favour what feels good over simulation accuracy
- **Easy to pick up, difficult to master** — simple, single-button input; depth comes from execution and decision-making, not control complexity
- **Match-first** — the match is the centre of the game; every other system exists to shape the matches you play and give them stakes
- **Depth without grind** — the club is competently run by default: players develop as expected, promotion brings in more money. The player steps in only where there's a genuine trade-off, never to improve on a default that already works. Neglect costs control, not effort: leave a problem and the club resolves it for you
- **Failure is meaningful** — the game does not guarantee the player's success; setbacks are part of the experience, not something to be designed away

## Inspirations

What's taken from each, and what's left. How the build order uses them is the [Roadmap](../../project/roadmap.md).

### Sensible World of Soccer

The model for the whole loop, and the match the game starts from. See [the SWOS overview](../../sources/swos/overview.md).

- **Takes** — tone, pace, the top-down view, one button with aftertouch, and the player-manager career where a signing is someone you then control
- **Leaves what its era forced** — seven skills fixed for life, a world sized to fit 1990s storage
- **Leaves its faults** — speed overwhelming every other attribute, players that can't be compared
- **Leaves its tactics editor** — for formations on a grid
- **One button stays.** In SWOS it began as a hardware limit; here it's a pillar

### Championship Soccer

The precedent for going past SWOS: it cloned SWOS's match, then built on it.

- **A deeper attribute model** — more attributes, with progression and decline
- **More ways to run a career** — a single player with no say over the team; a player-manager who is one player and picks the team; a player-manager controlling the whole side, as in SWOS; or a manager only
- **Takes** — the direction: the same match, deeper players, more ways into a career. Of its roles, player-manager and manager

### Football Manager

Deep in exactly the places SWOS is thin. See [the FM overview](../../sources/fm/overview.md).

- **Takes** — formations as positions on a grid; an attribute model deeper than SWOS's, with summary layers that keep it readable; and the depth of its management
- **Leaves** — its match engine as a reference for feel or input
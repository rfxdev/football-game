# SWOS — Overview

Sensible World of Soccer is the primary reference game for this project's arcade football feel. Kept split by concern so each piece can be read narrowly: [Match Mechanics](match-mechanics.md) (what happens once the ball is kicked), [Player Ratings](player-ratings.md) (attribute definitions and scale), [Tactics and Team Selection](tactics-and-team-selection.md) (the pre-match advisory layer), [Career Mode Mechanics](career-mode-mechanics.md) (valuation, wages, progression across a save).

## Strengths

- **The hybrid loop is the headline strength, not any single system.** SWOS pairs a full player-manager career — scout a player from a worldwide database, negotiate the transfer, manage the finances that follow, then control that signing on the pitch — with fast, frenetic arcade match play. Plenty of games do either half better in isolation; few combine both this tightly. See [Career Mode Mechanics](career-mode-mechanics.md).
- **The ball is never glued to the player.** A carrier with low Ball Control runs it too far ahead of himself and loses it, so how you play has to change with who you're controlling — the same input gives you a different game depending on the man on the ball. See [Match Mechanics](match-mechanics.md).
- **Aftertouch is the skill ceiling.** A stick and one button, but bending a shot around the keeper after it has left the boot takes real practice and stays satisfying long after the basics are learned.
- **Tactical complexity sits outside the match, not inside it.** Formation and role choices happen pre-match; in-match input stays a stick and one button however elaborate the tactic. Depth is added where it costs the player nothing at the moment of play. See [Tactics and Team Selection](tactics-and-team-selection.md).

## Trade-offs

Three of SWOS's best decisions are also its worst, depending on which way you look at them. Some began as hardware constraints rather than design choices — worth separating, because a constraint we no longer have is only worth keeping if it was load-bearing for the feel.

### One Action Button

The Amiga joystick had one button. The constraint came first; the design made a virtue of it.

- **Buys** — nothing to learn before playing and no animation to wait out. The skill ceiling lives in timing and aftertouch rather than a button chart.
- **Costs** — every attacking idea goes through the same tap/hold, so play skews heavily direct. Variety another game spends a dedicated button on isn't reachable.
- **For us** — the constraint is gone, the pillar isn't: single-button input is a design choice now. The open question is whether the missing variety can come from context and stick position instead of a second button.

### Seven Skills, Fixed for Life

Skills are [stored 0–7](player-ratings.md) — eight values per attribute. On 1990s hardware, a database this size made a small, immutable attribute set a storage decision as much as a design one.

- **Buys** — a squad readable at a glance and a transfer call made in seconds: is he better than the man he replaces, and can I afford him? Career mode never becomes a spreadsheet.
- **Costs** — no progression, no decline, no form or morale. A 19-year-old is exactly as good in his tenth season, so nobody is worth developing and scouting is a shopping trip.
- **For us** — storage is free now. The open question is whether depth can go up without the decision getting slower: ability that moves across a career, while buy/don't-buy stays a glance rather than a study.

### Fully Editable Tactics

Not a constraint — a deliberate choice. A tactic is a 35-entry table of where each player stands for every ball position, 240 positions available per player. See [Tactics and Team Selection](tactics-and-team-selection.md).

- **Buys** — real expression. How you want the team to play is genuinely representable, not picked from a list.
- **Costs** — hours in a grid editor to beat the 12 presets. Most players never open it, so most of the depth ships unused.
- **For us** — the ceiling is worth keeping, the entry cost isn't. The open question is whether the same expressiveness is reachable from a few high-level choices, with the grid underneath for anyone who wants it.

## Weaknesses

Unlike the trade-offs above, these buy nothing. Faults to fix, not balances to strike.

- **Speed overwhelms every other attribute.** [Player Ratings](player-ratings.md) calls it "by far the most crucial stat", and the strange part is how little raw movement sits behind that: top speed spans only ~35% from the slowest player to the fastest (928 to 1250 in engine units — see [Match Mechanics](match-mechanics.md)). A skilful slow player is close to useless regardless, which flattens squad-building into a hunt for pace.
- **Players can't be compared.** The squad screen gives a player's three best skills as a letter code and his value, and nothing else — so two midfielders are indistinguishable unless you already know the database by heart. The information exists; the UI simply doesn't surface it. See [Player Ratings](player-ratings.md).
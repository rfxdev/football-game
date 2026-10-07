# Career

SWOS-weight, with static attributes, as a player-manager controlling the whole side. A ladder, each rung playable on its own:

1. **Season mode** — league and cup fixtures, tables, everyone else's matches simulated. No squad changes. Needs CPU vs CPU simulation settled, as does every rung after it — see [Outside the Match](../../docs/README.md#outside-the-match)
2. **Squad upkeep** — injuries and suspensions carry between matches, squad status tiers (TRIAL, RES, LOAN)
3. **Transfer market** — the rung that makes it a career rather than a season: signing a player and then controlling him on the pitch is SWOS's headline strength, per [Strengths](../../sources/swos/overview.md#strengths). Buy and sell, domestic and foreign browsing, filters, part-exchange. With static attributes a player's value can be a fixed function of skills, position and nothing else. No negotiation: fee and wage come from skill and league. Contracts are indefinite, so selling is the only way a player leaves
4. **Finances and jobs** — wages tied to squad value, gate receipts to form, the sack, job offers, starting small. A signing's wage joins the bill. Wages adjust on promotion and relegation, but on a separate scale from revenue, so relegation opens a gap the adjustment doesn't close. Over the wage limit: no signings past a set margin, and a drag on board approval. Far enough over, the board accepts bids you can't refuse; selling first keeps the choice yours. See [Career Mode Mechanics](../../sources/swos/career-mode-mechanics.md)

## Beyond the Ladder

- **CPU clubs trading with each other** — every other squad changes over a save, not just yours
- **International management and tournaments** — picking from every league, then a 20-player squad for the finals
- **Your own world** — a career on football data the player imports, alongside the generated one, per [Licensing and IP](../../docs/decisions/licensing-and-ip.md#local-data)

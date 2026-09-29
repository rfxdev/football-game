# SWOS Career Mode Mechanics

How SWOS's Online Career mode ties player value, wages, and performance together. The valuation/skill insights below are sourced from a Jon Hare Q&A (`raw/jon-hare-qa-transcript.md`); the transfer, finance, and squad-status mechanics are sourced from the printed manual (`raw/manual-96-97.md`).

## Expensive Signings Can Still Be a Poor Fit

Players bought for large fees can underperform depending on the team they're in, the area of the pitch, and the tactic in use — not just randomness, but the same tick/cross fit-scoring described in [Tactics and Team Selection](tactics-and-team-selection.md), applied at squad-building time rather than mid-match. A club can pay a large fee and wage for a nominally strong player who is a poor fit for its tactic, and the tactics screen surfaces that mismatch before a ball is kicked — it just doesn't stop the signing from happening.

## Skill Scale Affects Performance, Not Just Price

Raising a player's skill value (the Q&A's example: 7 up to 15) changes actual in-match performance, confirmed directly rather than only inflating cost:

> Yes I am pretty sure all skill changes statistically altered the performance ability of players

That "7 to 15" isn't a modded database exceeding some shipped limit — [stats are stored 0–7 and the engine adds +8 for gameplay](player-ratings.md), so 8–15 is the normal effective range, not an overreach. The likely trap: the on-disk field has room for 0–15, and a modding tool that writes straight into it rather than through the intended 0–7 input can push a stat into the upper half *before* the engine's own +8 is applied — overflowing whatever fixed-width field holds the result and wrapping back down (15 + 8 = 23, which wraps to 7 in a 4-bit field). That would land a "maxed out" stat below even the worst normal value, which fits the transcript's opening anecdote — a nominally strong, expensive player performing like total ass — better than assuming it's just noise. This last step is our own inference from the arithmetic, not something either source states directly.

Bears on [Data Architecture — Open Questions](../../docs/design/tournament-and-career-mode/data-architecture-open-questions.md), §1 Dataset Scope and §6 Valuation Recalculation.

## Database Modding Stayed Within the Original Bounds

On whether editing the player database (roster updates, stat mods) risks the tuned game feel:

> As long as the minimums and maximums used by the original data are not exceeded database modifications should be fine

The constraint was the *range*, not the specific values: any population respecting the attribute bounds the simulation was tuned against is fair game. Bears on [Dataset Provenance](../../docs/design/tournament-and-career-mode/data-architecture-open-questions.md).

## The Transfer Market's Actual Mechanics

Buying a player splits into three paths: browse the **Domestic** market, browse the **Foreign** (worldwide) market, or bypass the market entirely and approach a club directly for a player who isn't listed for sale — the last option requires already knowing who plays where, and costs well over market value. Market browsing filters by position (keeper/defender/midfielder/attacker), by a specific skill (any of the 7 core attributes — see [Player Ratings](player-ratings.md)), and by budget. Offers can include cash plus up to two of your own players as part-exchange; the selling club accepts, counters, or flatly refuses.

## Club Finances Tie Wages and Gate Receipts to Squad Value and Form

Running costs and wages scale directly with the combined value of the squad — a valuable squad is expensive to maintain independent of results. Gate receipts scale with league form instead — doing well draws more revenue. Sustained overdraft risks the chairman sacking the manager, so squad value and on-pitch form pull the finances in different directions and both need managing.

## The Intended Progression Path Starts Small

The manual explicitly recommends starting a career at a lower-division club rather than a top team — reaching international management (the top of the career ladder) from a big-club start is possible but, per the manual, "much less satisfying" since there's less room to climb. Job Offers are the mechanism that surfaces this climb: better offers appear as your managerial record improves, and accepting one at a season's end moves you to that club or country for the next season.

## Squad Status Tiers Track a Player's Path to a Full Contract

New arrivals enter as **TRIAL** — untested — and are automatically promoted to **RES** (Reserve) after a single 1st-team appearance. Reserves need a few more 1st-team games to earn a full contract. **LOAN** players are a separate, weaker category drafted in by the chairman just to fill numbers, not a development pipeline. All three statuses sit below full squad members in the pecking order shown on the squad screen.

## Suspensions and Injuries Remove a Player from Selection Entirely

Cards accumulate into suspensions per competition: a single yellow carries no suspension (except a second yellow in the same competition, which converts to a one-match ban), while red cards stack — 1 red = 1 match, 2 reds = 2 matches, 3 reds = 3 matches. Injuries have their own severity ladder: a "knock" (bandaged head icon) doesn't hurt current form but raises the odds of a worse injury next knock; a numbered injury sidelines a player for that many matches (or an unknown, probably-4+ span if marked "?"); a season-ending injury benches them for the rest of the year. Suspended or injured players can't be selected at all — not even to the bench.

## International Squads Are Capped at 20 for Tournament Finals

Managing a national team means picking from every eligible player across every league in the world, but once that team qualifies for a major finals (World Cup, European Championship, Copa América, etc.), the squad locks to 20 players for the entire tournament — a harder constraint than domestic squad-building, where the roster isn't capped the same way.

## Open Questions

- **What actually triggers or calculates an injury?** This is fundamentally a match-engine question — see [Open Questions in Match Mechanics](match-mechanics.md#open-questions) — but it overflows into career mode since the outcome (knock, numbered injury, season-ending injury) determines a player's selection eligibility across the following matches, per [Suspensions and Injuries](#suspensions-and-injuries-remove-a-player-from-selection-entirely) above.

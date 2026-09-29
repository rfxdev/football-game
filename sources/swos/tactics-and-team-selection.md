# SWOS Tactics and Team Selection

The pre-match advisory layer that sits between the match engine and career mode: it predicts squad fit before kickoff but doesn't touch what happens once the ball is live, and it's what feeds transfer and valuation decisions in a career. Sourced from a Jon Hare (SWOS co-designer) Q&A, kept in full at `raw/jon-hare-qa-transcript.md`, plus the tactics-editor mechanics as documented in the printed manual (`raw/manual-96-97.md`). See [Match Mechanics](match-mechanics.md) for what actually happens in a match, and [Career Mode Mechanics](career-mode-mechanics.md) for how this feeds transfers and valuation.

## The Editor Grid: 35 Ball Zones, 240 Player Positions

Every tactic — the 12 built-in formations and the six custom `User A`–`User F` slots — is defined against an invisible grid: 35 zones the ball can occupy, and 240 positions any one player can occupy relative to it. Moving the ball around the editor snaps every player to their default position for that zone; stopping and dragging an individual player instead fixes a new position for that zone only. A tactic is really a 35-entry table of "where does each player stand when the ball is here," not one fixed formation shape.

Editing tools:

- **Copy** — lock two or more ball zones to share identical player positions, instead of hand-placing a formation twice for zones that should look the same.
- **Flip on/off** — mirrors positions left-right, and drives player *pairings*: up to five two-player partnerships (goalkeeper excluded) whose positions mirror each other automatically, so editing one full-back's positioning edits the other side's for free.
- **Import** — start a custom tactic from any of the 12 presets, or reload a previously-saved custom tactic to keep tweaking it.
- **Undo / Abort / Save-Exit** — undo the last change; discard the whole editing session back to defaults (Abort); or exit with a choice to save the changes or keep them for this session only without saving (Save-Exit).

## Assistant Coach Advice Doesn't Cover Bench Changes

The tick/cross evaluation described above only fires for changes made from the pre-match tactics and squad screens. Swaps made from the in-match Manager's Bench (see [Match Mechanics](match-mechanics.md)) get no Assistant Coach feedback at all — a mid-match reshuffle is a blind bet on fit, not a scored one.

## The Manual's Own Design Guidance

Distilled from the manual's own tactical hints:

- Pull central midfielders slightly behind the ball rather than sitting level with it.
- Have wingers track back and follow the ball rather than holding the touchline statically.
- Winger speed matters more than most of a winger's other attributes.
- Let full-backs push forward to overlap; use Flip pairings so rebalancing one side (more attacking vs. more conservative) doesn't require re-editing both sides by hand.
- With two strikers, drop one slightly deeper to link play — he ends up closer to the ball and scores more of the position-fit "contribution" than a striker who stays flat on the last defender.

## Training Mode Is a Consequence-Free Sandbox

Training pits your own 'A' team against your own 'B' team — same engine as a real Play Match, but nothing is recorded against the season. It's the intended place to trial a new tactic or a new signing (via "Use Match Team" to load your actual current squad as the 'A' side) before committing it to a competitive fixture. Limited to one training match between each scheduled match.

## Ticks and Crosses Predict AI Performance, Not Human Performance

The tactics screen's red X / green tick indicators show how a player is expected to perform *under AI control* — the same evaluation used to judge every AI team — not a live modifier applied to a human-controlled player:

> X and ticks show you how the team perform under AI control and in result calculations (similar to how all AI teams are evaluated), if you selected a team in manage mode and watched the games only you would find by chasing ticks your team will perform better.

## Toggling a Position Doesn't "Reset" Anything

A long-running player myth: swap a player to the reserve keeper's slot and back to turn a red X into a green tick. Confirmed as placebo:

> No this will do nothing.. all this tick means is that he is better than the reserve goalkeeper.. the X before meant he is not so well suited in the new position after you made the formation change and that he preferred the old formation.

An advisory display this easy to mistake for a live stat cost SWOS a decade of community myth-building.

## Some Formations Are Eccentric By Design

5-2-3 is called out as a deliberately unusual, more attacking variant of 5-4-1, with no default team using it as a reference tactic — which is why plugging in either recognised wing role produces confusing ticks:

> 5-2-3 is a rather eccentric additional formation, a slightly more attacking variant of 541... remember with the Xs and ticks they are only computer guesses as to how you will perform if you were an AI team, of course if you can pick the passes to pushed up wingers then it can be of benefit to you.

## A Poor Tick Doesn't Block Selection or Guarantee a Bad Result

A human player can still succeed with a "wrong" tick — the display is a prediction of AI-controlled performance, not a rule. This same fit score is what let expensive Online Career signings underperform depending on team and tactic; see [Career Mode Mechanics](career-mode-mechanics.md).

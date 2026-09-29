# Ideas

Where the game could go — before any of it has been checked against anything. No commitment, no promise to a player, no acceptance criteria. Just notes worth not losing.

Add a line whenever one occurs. Don't build a case for it here — that's what the gate is for.

## After the SWOS Match Clone

The planned phases end at a match clone. Past that, two stages: reach parity with SWOS's hybrid loop — the match plus the manager game around it — then go beyond it.

### Stage 1 — Hybrid Parity

What SWOS has around the match that the roadmap doesn't build yet.

#### Getting Into a Match

- **Front end** — menus, team select, friendlies, pause. The match clone has no way in except a debug scene
- **Replays and highlights**

#### Controls and Players

- **Two-player mode** — couch co-op, a pad per player. The input seam that makes it cheap is in [Player Controller and Input](../docs/design/match-engine/player-controller-and-input.md)
- **Keyboard controls** — bound to the same actions as the pad, per [Gamepad Input and Steam Deck Parity](../ways-of-working/gamepad-input-and-steam-deck-parity.md)

#### Tactics Beyond Formations

Formations as grid layouts are planned — [Formation and Shape System](../docs/design/match-engine/formation-and-shape-system.md), and [6.2 Team Management](milestones/6.2-team-management.md) for picking and changing them. What that leaves out:

- **Fit that reads as advice** — per-player suitability for their cell, unmistakably a prediction. SWOS's tick/cross display bred a decade of myth — see [Tactics and Team Selection](../sources/swos/tactics-and-team-selection.md)
- **Try it before it counts** — SWOS's A-team-vs-B-team training match, for a new formation or a new signing
- **See the shape while choosing** — a preview pitch on the formation screen, with a ball moving round it and the block following
- **Team and player instructions** — mentality, pressing, a winger cutting inside. Left out so formations carry it; worth revisiting if two formations that should play differently don't

#### Career With Static Attributes

SWOS-weight, as a player-manager controlling the whole side. A ladder, each rung playable on its own:

1. **Season mode** — league and cup fixtures, tables, everyone else's matches simulated. No squad changes. Needs [CPU vs CPU Simulation](../docs/design/tournament-and-career-mode/cpu-vs-cpu-simulation.md) settled, as does every rung after it
2. **Squad upkeep** — injuries and suspensions carry between matches, squad status tiers (TRIAL, RES, LOAN)
3. **Transfer market** — buy and sell, domestic and foreign browsing, filters, part-exchange. With static attributes a player's value can be a fixed function of skills, position and nothing else. No negotiation: fee and wage come from skill and league. Contracts are indefinite, so selling is the only way a player leaves
4. **Finances and jobs** — wages tied to squad value, gate receipts to form, the sack, job offers, starting small. A signing's wage joins the bill. Wages adjust on promotion and relegation, but on a separate scale from revenue, so relegation opens a gap the adjustment doesn't close. Over the wage limit: no signings past a set margin, and a drag on board approval. Far enough over, the board accepts bids you can't refuse; selling first keeps the choice yours. See [Career Mode Mechanics](../sources/swos/career-mode-mechanics.md)

Open:

- **Is it a career without rung 3?** Rungs 1–2 are a season mode. SWOS's headline strength is signing a player and then controlling him on the pitch — see [Strengths](../sources/swos/overview.md#strengths)
- **Do CPU clubs trade with each other, or only with you?** Without it every other squad stays the same for the whole save
- **Why buy anyone if nobody gets better or worse?** Covering injuries and suspensions, fixing a tactic's weak slot, and a bigger budget as you move up. Enough for SWOS; possibly thin across many seasons
- **A squad screen where players can be compared** — fixes SWOS's [worst UI weakness](../sources/swos/overview.md#weaknesses) without any new systems
- **Generated world or imported one** — [Data Architecture §2](data-architecture-open-questions.md#2-dataset-provenance)
- **International management and tournaments** — 20-player squads for finals, picking from every league

### Stage 2 — Beyond SWOS

Tracks, mostly independent of each other.

#### Match Play

- **Variety without a second button** — every attacking idea in SWOS goes through the same tap/hold, so play skews heavily direct; variety another game spends a dedicated button on isn't reachable. Whether context and stick position can carry that instead. The Amiga's one-button joystick is why the constraint existed, but [single-button input is a pillar](../docs/design/game-vision-and-design-goals.md) now, not a hardware limit — see [Trade-offs](../sources/swos/overview.md#one-action-button)

#### Player Depth

- **Modernised attributes** — more than SWOS's seven, informed by [FM](../sources/fm/player-attributes.md)
- **Attributes that drive AI** — mental attributes such as Positioning and Decisions shape how the 21 uncontrolled players behave, adding depth without touching single-button input
- **Ability that moves across a career** — progression and decline, which gives attributes a reason to change. Links career and attributes. Championship Soccer did this on top of a SWOS clone
- **Youth intake and retirement** — follows from progression. How long saves avoid filling up with old players is [Data Architecture §4](data-architecture-open-questions.md#4-statistics-granularity-and-population-lifecycle)
- **Form** — short-term swings on top of fixed ability. A cheaper way to make selection matter than full progression
- **Summary ratings over detail** — FM-style star ratings or role suitability, so extra attributes don't slow the buy/don't-buy call
- **Fix speed dominance** — SWOS's [biggest balance fault](../sources/swos/overview.md#weaknesses). More attributes do nothing if pace still decides everything

#### Management

- **Career roles** — Championship Soccer's range past SWOS's player-manager controlling the whole side. Manager only, directing from the touchline, is in the [vision](../docs/design/game-vision-and-design-goals.md#the-game) and only works once a directed match is as interesting as a played one. A player-manager who is one player on the pitch is possible. A lone player with no say over the team is lower interest
- **Management-sim depth** — transfers, finances and running the club, towards FM's depth. The furthest off of any track. Bounded by the [vision](../docs/design/game-vision-and-design-goals.md#scope--boundaries): each system still has to shape the matches. Each layer replaces a competent default with a trade-off: player desires, such as refusing to drop a level or take a pay cut; renewals; negotiation, only as trade-offs such as wage for length; financial fair play, with points deductions that reach the match

#### Presentation

- **Uplift to 3D** — the ball already simulates height, so 3D could be a new renderer over the same simulation rather than a new engine. Only possible if simulation and rendering stay separate, which is what running matches headless needs anyway. The [style guide](../docs/design/visual-style-guide.md) currently says 2D sprites, and the Deck has to run it
- **A camera that isn't straight top-down** — a tilted or broadcast-style view. A step towards 3D that doesn't require it
- **UI overhaul** — squad comparison, transfer browsing, the tactics preview. Most of what makes SWOS's manager side hard to use is the UI

#### World

- **Community packs** — kits, sprites and team data, loadable but not hosted — hosting is ruled out by [Licensing and IP §3](../docs/decisions/licensing-and-ip.md#3-no-licensed-football-content)

## Graduating an Idea

When one is next, run it through [the gate](../ways-of-working/spec-chain.md#the-gate).

- Passed → onto the [Roadmap](roadmap.md), into a phase
- Declined → `docs/decisions/`, with why

## Parked

- None yet.
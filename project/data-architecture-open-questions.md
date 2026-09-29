# Data Architecture — Open Questions

Questions to answer before picking the persistence schema and storage technology. The working shape is SQLite as source of truth with on-demand hydration into memory for simulation — **not decided**.

Each question changes how data is structured or stored, not just how a feature behaves. Revisit each before implementing the relevant subsystem, not after. Nothing carries a default unless it says so.

Ordered by dependency — work top-down, because the earlier answers change what the later ones mean.

Relevant prior art: [SWOS Career Mode Mechanics](../sources/swos/career-mode-mechanics.md) — how skill scale, valuation, and club finances tie together in the game this one is inspired by. Part of a split covering SWOS as a whole — see [overview.md](../sources/swos/overview.md).

## Scope and Source

What data exists at all. Everything below this group scales with it.

### 1. Dataset Scope

Whether 50–150k players at up to 40 attributes is a deliberate target or scope that crept in during architecture discussion.

*Current thinking:* 150k is likely high; expect fewer entities. Not yet a number.

Why it matters:

- Every question below scales with it. At a small enough population, retention strategies and precomputed valuation columns stop being necessary at all
- Check against [Game Vision and Design Goals](../docs/design/game-vision-and-design-goals.md) and the scope boundaries in [AGENTS](../AGENTS.md), which rules out management-sim depth, before any schema work

### 2. Dataset Provenance

Where the initial world comes from — generated at new-career time from a seed, or built from an external source and shipped as a prebuilt database?

*Under consideration:* condensing FM26's database as the source, held locally rather than distributed.

**Distribution context — a working assumption, not a decision:** personal hobby project, sideloaded onto the developer's own Deck rather than published to the Steam store. Real data (FM26, SWOS 2020, squad-data sites) may be used locally and is never committed to the repo. [Licensing and IP](../docs/decisions/licensing-and-ip.md) can be amended if the assets licence conflicts.

If that holds, the licensing and distribution exposure is resolved and what remains is architectural.

**The requirement that falls out:** a fresh clone of the public repo has no licensed data, so it must still produce a working game. The generator is therefore the default path regardless — not a chosen alternative — and real data is a local import layer on top. Both get built; the open question is the seam between them.

Still open:

- The import format and how much of the schema it pins. A local-only importer can track schema changes freely; one meant to survive game updates cannot
- How closely the generator's output must match real-data shape, so a career started on one doesn't feel unlike a career started on the other
- Generating a full population with relationships on first run is a startup cost, not a free alternative

Decide alongside:

- **Test fixtures must be synthetic.** GdUnit4 suites and any CI cannot depend on uncommitted data, so the generator has to produce usable test worlds from the start
- **Keep licensed data out by construction, not discipline** — a gitignored path or `user://`, settled before an importer exists. [AGENTS](../AGENTS.md) notes that removing anything from a public repo means rewriting history
- Reverts if the distribution model changes. Generator-as-default keeps that reversal cheap

## Simulation and Schema Shape

### 3. Simulation Scope

How other matches on a matchday resolve, and how many leagues get that treatment — only the division holding the user's club, or the full pyramid across every loaded competition?

**Previously recorded as settled; reopened.** The requirement splits two ways, and they cost very differently:

- **Presentation only** — goal alerts and a live table during the player's match. Satisfiable by pre-resolving other matches and replaying their event timelines as the player's match runs. Nothing is concurrent; the league only appears live
- **AI-reactive** — teams in other matches genuinely respond to live scores elsewhere (chasing a winner because a title rival is drawing). Needs real lockstep on a shared clock and a shared matchday context

Why it matters:

- Sets the hot in-memory working set per matchday — roughly 500–750 players per division, to be confirmed against final squad sizes
- Decides whether a shared matchday context is needed at all, or just an event timeline per match with timestamps
- Bears directly on [CPU vs CPU Simulation](../docs/design/tournament-and-career-mode/cpu-vs-cpu-simulation.md). Pre-resolve-and-replay costs the displayless-engine option nothing; genuine lockstep would need N concurrent instances

### 4. Statistics Granularity and Population Lifecycle

How detailed is statistics tracking, does the level vary by league, and what happens to entities as seasons accumulate?

- Match-level detail for every player in every loaded league
- Match-level detail for followed leagues only; season aggregates elsewhere
- Season aggregates everywhere

Retirement and youth intake sit here too: the population isn't static, so a long save drifts upward. Do retired players stay in full, archive, or collapse to a record stub?

Why it matters:

- Sets the save's growth rate across a long campaign. Match-level everywhere is likely an order of magnitude more rows per season than aggregates, and it compounds every season
- Sets schema shape: a continuously-growing `player_match_stats` table, a bounded-per-season `player_season_stats` table, or both with different retention rules
- Full detail everywhere probably needs a retention strategy — collapse older seasons into aggregates after N seasons — to keep save size bounded
- Stats rows and entity rows grow independently; a retention rule for one is not a retention rule for the other

### 5. Attribute Progression

What triggers progression and regression — a periodic tick (weekly training), end of season, or both? Every loaded player, or only actively tracked leagues?

Why it matters:

- Sets write frequency against the players table: weekly batch versus once a season. A scheduling and cost question, not a schema-shape one like question 4
- Scoped to tracked leagues only, background players need a separate and cheaper statistical pass so they don't go stale across a long save

### 6. Valuation Recalculation

Cadence and trigger conditions for recalculating a player's market value.

*Proposed, not confirmed:* store as a column, recalculate on the same cadence as progression, plus on-demand triggers for notable events — standout performance, new contract, promotion or relegation.

Why it matters:

- Decides whether transfer browsing and sorting hits a precomputed indexed column, or recomputes a formula across thousands of rows every time a screen opens

## Storage Mechanics

### 7. Save Model

*Proposed:* one SQLite file per career. Deleting a save is deleting a file; no `save_id` column on every table, in every index and every `WHERE` clause.

Still open:

- Where static reference data lives — nations, competition structures, name corpora. Duplicated into every save file (simple, wasteful), or a separate read-only database the save attaches to (`ATTACH DATABASE`, cross-database joins, one copy)
- Autosave cadence, and what survives an interrupted write. Steam Deck suspend/resume makes this routine rather than an edge case

### 8. Schema Migration

Whether to commit to a schema-version pragma and forward migrations from the first save format.

Why it matters:

- A career save spans months of real time, and the game will ship updates in that window. Adding an attribute in v1.1 cannot brick a v1.0 save
- Near-free to adopt now, near-impossible to retrofit once saves worth keeping exist. A fifteen-season career is worth protecting even if it never leaves your own Deck
- File-per-career means migration runs per file on load, independently

## Standing Rule

Not an open question — a constraint on anything above that feeds simulation.

- Query results consumed by simulation need explicit `ORDER BY`. Unordered results break reproducibility, which [CPU vs CPU Simulation](../docs/design/tournament-and-career-mode/cpu-vs-cpu-simulation.md) depends on if the displayless-engine option survives
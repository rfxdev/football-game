# football-game

Top-down 2D arcade football, inspired by Sensible World of Soccer. Non-profit, open source.

**Documentation-first — no source code yet.** Most work here is writing or restructuring docs.

## Non-Negotiables

**Godot 4.x, GDScript, editor-first. Not Unity** — evaluated and rejected over Linux/Deck build friction. Be sceptical of Unity-shaped advice; it's more abundant online and some of it solves problems Godot doesn't have. C# is a later option, never the starting point.

**No licensed football content, no material from other games.** The repo is public, so removing infringing material means rewriting history. Ruled out:

- Real teams, players, leagues, competitions, crests, kits
- Name generators seeded from real squads; generated content landing on a real club's name, city and colours together
- Assets extracted from another game, including pixel-copied HUD layouts
- Unknown, non-commercial or personal-use-only licences (CC BY-NC especially)

Copying another game's *feel* is the point. Copying its files is not.

**Design pillars** — check proposals against these (full reasoning in [Game Vision and Design Goals](docs/design/game-vision-and-design-goals.md)):

- Fun over realism
- Easy to pick up, difficult to master — single-button input
- Match-first
- Failure is meaningful

In scope alongside single-player: local couch co-op.

Out of scope: online multiplayer, mobile, management-sim depth.

## Where Things Live

- **[`docs/`](docs/README.md)** — what the game is. Split three ways: `design/` (intent and systems), `manual/` (player-facing), `decisions/` (settled, with reasoning — the stack and the IP policy)
- **[`ways-of-working/`](ways-of-working/README.md)** — how it gets built
- **[`project/`](project/README.md)** — where the work stands

If it's a decision you'd make at the keyboard, it's `ways-of-working/`.

Its index is imported rather than summarised here — the pipeline and the delivery rules apply to every session:

@ways-of-working/README.md

## Conventions

- **Keep docs short.** Bullets over prose; state the rule, don't restate rationale recorded elsewhere. Solo hobby project — review time is the scarce resource
- **Don't count things that change.** No totals of phases, milestones, files, sections, questions or words — describe or link them instead, so adding one never means updating a number somewhere else
- Prefer editing existing docs to adding new ones
- **Read along the constraint order**, not by folder size — the chain is in [`docs/README.md`](docs/README.md). Docs are granular so narrow work stays in narrow context; widen deliberately:
  - **Upstream, always.** Design work reads the vision, `decisions/` and `manual/` first — short enough together that there's no call to make. To test whether something else belongs, ask what would make the change wrong: a settled choice, or what the player was promised
  - **Sideways, where systems interlock.** `design/match-engine/` is one system split across files — take the folder, not the file
  - **Downstream, when changing a constraint.** A revised decision may have orphaned design docs written against the old one
  - **Never everything, unasked.** Reading the full set is a task in its own right — `/doc-consistency`, or an explicit request. Being stuck is not a reason to load it
- Docs carry no status line; status lives in [`project/doc-review.md`](project/doc-review.md) (temporary — delete it and this bullet when the review ends)
- British English

## When Code Exists

- **GdUnit4.** Correctness tests from day one; feel-threshold tests only after a mechanic feels right, always as a range
- **Typed GDScript**, `gdlint` for style
- **No feel value as a literal in a script** — friction, acceleration, shot power, AI reaction time must be tunable without a code edit
- **Never build to test what the editor can show you**

## Licensing

Code MIT, assets CC BY-SA 4.0. See [Licensing and IP](docs/decisions/licensing-and-ip.md).
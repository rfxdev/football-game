# Project

Where the work stands — what gets built next, and the files that record it. [`docs/`](../docs/README.md) holds what the game *is*; [`ways-of-working/`](../ways-of-working/README.md) holds how it gets built.

The build order is [Roadmap](roadmap.md); [Ideas](ideas.md) holds what isn't on it yet. How a milestone file is written is below.

## What's Here

| File | What it covers |
| --- | --- |
| [Roadmap](roadmap.md) | The build order — phases, milestones, and the notes that span them |
| [`milestones/`](milestones/) | One file per milestone: what it adds, how it exits, what its playtest is asking. Started from [TEMPLATE.md](milestones/TEMPLATE.md) |
| [Ideas](ideas.md) | Where the game could go, before any of it has been checked against anything. No commitment. The outline, a line per area |
| [`ideas/`](ideas/) | The ideas themselves, a file per area |

## Milestones

A **milestone** is the gated unit of work: one file in [`milestones/`](milestones/), one playtest session, one exit decision. A **phase** groups them and is a claim about what the project can do — *"every on-ball action works"* — with no file and no gate of its own. Phases live in [Roadmap](roadmap.md).

- **The milestone file owns everything specific to it** — why it exists, what its playtest is asking, its failure modes, the sprites it first needs, its tests. The roadmap owns the order, and only the notes that span phases
- **Anything finer than a milestone is content inside its file, not a milestone of its own.** *Tap for pass* and *hold for shot* are lines in [1.2 Kicking](milestones/1.2-kicking.md), not entries in the build order
- **Files are named `<phase>.<milestone>-<slug>.md`**, so the directory reads in build order. Renumbering renames files and breaks inbound links, so re-cut the order deliberately rather than casually, and cite milestones by name as well as by link
- **Link to the design docs a milestone depends on rather than restating them.** A milestone file says what to build and how it will be judged, not how the system works
- **[TEMPLATE.md](milestones/TEMPLATE.md) is the file's shape** — the fields, in order, and what each is for. Copy it to start a new milestone; the sections below say how to decide what goes in them

## Exit Criteria

**A milestone exits against the acceptance criteria in the design docs it links — not against "it feels right", and not against SWOS directly.** Until the clone plays, most of those criteria are written from [the SWOS research](../sources/swos/), which is disassembly-grade — hardcoded speeds, frame counts, the formula a passive duel resolves on — so they are checkable in a way that taste is not. How SWOS gets into a design doc is [Writing From SWOS](../ways-of-working/spec-chain.md#writing-from-swos).

Three routes out, set by what the criteria say:

- **They fix a number** — matching it is the exit condition, and *Asking* is thin or absent
- **They are a range judged by playing** — the milestone falls back to a playtest judgement and *Asking* carries the weight. See [Playtesting](../ways-of-working/playtesting.md)
- **There is no design doc** — Phase 0 is invisible scaffolding, the *neither* route in [the spec chain](../ways-of-working/spec-chain.md), and exits on working

A milestone that is correctness- or variety-shaped rather than feel-shaped — most of Phase 5 — skips *Asking* and *Session shape* entirely rather than forcing a playtest protocol where none is warranted.

## Status

A milestone file carries a **Status**:

- **Outline** — it holds what the roadmap already knew: the summary and whatever notes came with the sequencing decision. Every file starts here
- **Ready** — every field this milestone is going to have is written. For most that means the playtest and testing fields; for a scaffolding milestone that legitimately has neither, it means the decision to omit them has been taken and recorded
- **Done** — built, and the exit decision taken. The file is now a record of what was built and isn't reopened: a later change to the design it delivered goes through [the spec chain](../ways-of-working/spec-chain.md), and later milestones reach its tests through 360 Testing

**Fill the playtest and testing fields in shortly before the milestone is built, not up front** — once the milestone before it is Done. A session protocol written today for a milestone five phases away is fiction about a game nobody has played — the same reason the manual isn't written up front in the spec chain.

**Ready holds only while the file matches its design.** When it stops matching — the file has drifted, or a design doc it links has changed since — it goes back to Outline until the two agree again.

Filling in a milestone, or checking a filled one against its design, is the [`milestone-reconcile`](../.claude/skills/milestone-reconcile/SKILL.md) skill. It follows the process above rather than adding to it.

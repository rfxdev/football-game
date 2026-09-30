---
name: milestone-reconcile
description: Fill in or check a milestone file in project/milestones/, from a bare Outline to a fully written file, so it is a blueprint for delivering the design — every deliverable traced to the design doc that specifies it and every part of the design it owns delivered, the spec chain's gate applied, those docs complete enough to build from, every test considered against Automation Testing, and the 360 review of earlier milestones done. Follows the documented process and reports gaps in it rather than filling them. Use when asked to write, fill in, check, review or make ready a milestone, before building one, or after a design doc a milestone links has changed. Takes the milestone number or filename as an argument.
---

# Milestone reconciliation

A milestone is a blueprint for delivering the design. It says what to build and how it will be judged; the design docs say what the thing is. Anything the milestone delivers that the design doesn't specify is a gap in the design, not content for the milestone.

Works on a milestone from Outline to Ready. On a blank one the steps below write it; on a filled one the same steps check it. A Done milestone is a record — report what's found, but don't rewrite it.

**Follow the process, don't extend it.** The rules live in the docs read in step 1. Where they don't answer a question this milestone raises, tell the user it's a process gap and name the doc that should own it. Don't invent a rule to get past it.

Show the user the outcome of each step and agree it before moving to the next.

## 1. Read

- The milestone file, its entry in [Roadmap](../../../project/roadmap.md), and Roadmap's *Notes on the Order*
- [Project](../../../project/README.md) → *Milestones*, *Exit Criteria*, *Status*, and [TEMPLATE](../../../project/milestones/TEMPLATE.md)
- [The Spec Chain](../../../ways-of-working/spec-chain.md), [Automation Testing](../../../ways-of-working/automation-testing.md), [Playtesting](../../../ways-of-working/playtesting.md)
- Upstream, per AGENTS.md → Conventions: the vision, `docs/decisions/`, and the Player Manual once it exists
- Every design doc in `docs/` the milestone's deliverables touch. Often there is none yet — step 2 writes it
- Where the milestone links a doc that no longer exists, its copy in `archive/`, for decisions worth keeping. Never as the spec
- The sections of [`sources/swos/`](../../../sources/swos/) that cover the deliverable — input for writing or checking a design doc per The Spec Chain → *Writing From SWOS*, never what the milestone is judged against
- Every earlier milestone in build order: what it delivers, its Testing and 360 Testing. Step 4 walks them

## 2. Trace to the design

Trace both ways. **Forward:** for each thing the milestone delivers — the summary, Attributes, Sprites, and any Note that commits to building something — find what specifies it:

| Deliverable | Route | Manual entry | Design doc | Acceptance criteria | Derived from |
| --- | --- | --- | --- | --- | --- |

Route is *told*, *felt* or *neither*, per The Spec Chain's *Three Routes In*.

**Backward:** from each design doc the milestone touches, take the parts the Roadmap's build order puts at this milestone rather than at a neighbour, and check the milestone covers each.

Sort Notes as you go. A hazard, failure mode or judgement call belongs in Notes. A decision that later work is built against — a value, a unit, an anchor, a convention — belongs in a design doc or `docs/decisions/`, with the Note linking to it.

Apply The Spec Chain's *The Gate* to each deliverable: the pillars, the manual's controls table for anything *told*, and Licensing and IP wherever content is involved — Sprites especially.

Flag:

- **Not in the design** — the milestone delivers something no design doc specifies
- **Missing** — design the build order puts here that the milestone doesn't deliver
- **Overlap** — a deliverable a neighbouring milestone also claims, or one this milestone's summary says it leaves out
- **Decision in Notes** — a decision recorded only in the milestone
- **Fails the gate** — against a pillar, an unpriced cost to the controls table, or a licensing problem
- **Upstream incomplete** — a *told* deliverable with no manual entry; a design doc with no acceptance criteria for it; an Open Question the build would have to answer
- **Restated, not linked** — design content copied into the milestone, against Project → *Milestones*
- **Wrong links** — a linked doc that doesn't specify this, or a doc that does and isn't linked
- **Dead links** — a link to a doc that no longer exists. Point it at the doc that now specifies it
- **Unrecorded departure** — a design doc differs from the `sources/swos/` section it is *Derived from* without saying so, or inherits from SWOS with no *Derived from* line
- **Judged against SWOS** — a milestone field that points at `sources/swos/` as its exit rather than at a design doc's criteria

A gap in a design or manual doc is fixed in that doc, by The Spec Chain — never patched into the milestone. Where the doc doesn't exist yet, write it now, from the milestone and `sources/swos/` per The Spec Chain → *Writing From SWOS*, and keep it to what this milestone needs: extend an existing doc before starting a new one, per AGENTS.md → *Split by what gets opened together*. Otherwise ask the user whether to fix it now or leave it flagged.

A fix that changes a design or manual doc changes a constraint, so read downstream per AGENTS.md → Conventions: any other milestone linking that doc and no longer matching it goes back to Outline, per Project → *Status*. List them for the user.

## 3. Fill the fields

Work through TEMPLATE's fields in order, deciding each by the doc that owns it: Asking and Session shape by Project → *Exit Criteria* and Playtesting → *What a Session Asks*; Attributes and Sprites by Roadmap's notes. Every field ends up written or deliberately omitted, and an omission is recorded, per Project → *Status*.

- Asking, any threshold range and any fixed value come from the design doc's acceptance criteria. If the criteria aren't there, that's a step 2 gap, not something to write here
- **Timing.** Per Project → *Status*, these fields are filled once the milestone before it is Done. If it isn't, tell the user before going further

## 4. Tests

**Testing.** Candidates come from:

- Every acceptance criterion for this milestone's deliverables
- For a *neither* deliverable, which has no design doc, the deliverable itself as the milestone describes it
- Automation Testing's standing items this milestone first makes relevant — *Determinism* once simulation code exists, *Invariants* this milestone introduces
- Anything step 2 surfaced

List them all, including the obvious ones:

| Candidate | Criterion | Automation Testing rule applied | Verdict |
| --- | --- | --- | --- |

Judge each against Automation Testing — *What a Test Has to Earn*, *Threshold Tests*, *Fixed-Value Tests*, and *360 Testing*'s own-deliverable rule. A candidate those rules can't decide is a process gap: raise it, don't rule on it.

**360 review.** Walk every earlier milestone in build order and ask, per Automation Testing → *360 Testing*: what can now be asserted about it that couldn't before, and which of its tests rest on assumptions this milestone breaks? New invariants go in the shared per-tick check, per *Invariants*. Show the walk even when it finds nothing — the review is done when the 360 Testing field is written or its omission recorded.

## 5. Write up

- Write the agreed fields in TEMPLATE's order. Link, don't restate
- Leave Notes from the Outline alone unless a step contradicted one, and say which
- Set **Status: Ready** once every field is written or its omission recorded. A Ready file that no longer matches its design goes back to Outline, per Project → *Status*
- Any upstream gap still open blocks the build under The Spec Chain — say so
- Report briefly: trace gaps, fields written or changed, other milestones sent back to Outline, tests kept and cut, the 360 outcome, and process gaps found
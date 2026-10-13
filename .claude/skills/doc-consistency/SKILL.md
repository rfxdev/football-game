---
name: doc-consistency
description: Keep the documentation set consistent. Finds every claim stated in more than one place, stated in a doc that doesn't own it, or handed off to a doc that doesn't take it on. Folds redundant copies into the owning doc, reconciles deliberate copies that have drifted, and moves misplaced claims and orphaned handoffs to their owner, fixing the index where it's silent. Use for a duplication, drift, placement or consolidation pass over the docs, once a documentation change has landed, or after changing a rule that appears in several places.
---

# Documentation consistency pass

Failure modes, all about where a claim lives:

- **Redundancy.** It is stated twice and shouldn't be.
- **Drift.** It is stated twice for good reason, and the copies no longer agree.
- **Misplacement.** It is stated once, in a doc that doesn't own it.
- **Orphaned handoff.** A doc defers a claim to another doc that doesn't take it on, or that defers it straight back.

Drift and orphaned handoffs are the dangerous ones: neither file looks wrong on its own. All of them fall out of the same inventory, so find them in one pass.

None can be grepped — the second copy is rarely worded like the first, and a handoff only looks wrong from the other end. Read the whole set at once and work from claims.

An optional argument narrows the pass to one folder (`ways-of-working`, `docs`, `project`, `sources`). No argument means everything.

## 1. Read everything

Start from a clean tree — `git status --short` should be empty of doc changes. The pass edits many files at once, so the diff is the review surface and `git checkout .` is the undo. If the tree is dirty, say so and stop. Mid-change, [doc-review](../doc-review/SKILL.md) covers placement for the doc being changed.

```bash
find AGENTS.md CONTRIBUTING.md README.md docs ways-of-working project sources -name '*.md' | sort \
  | xargs -I{} sh -c 'printf "\n\n===== %s\n" {}; cat {}'
```

Read all of it before forming an opinion. Include the short files — a 15-word placeholder that restates a populated doc is redundancy, and deleting it is the cheapest fix available.

## 2. Inventory the claims

For every normative statement — a rule, a constraint, a rationale, a target — note the claim and **every** file that states it, not just the first two. Work from claims, not phrases: the same rule appears as prose in one doc and a bullet in another.

Note every handoff too — "X is Y's", "belongs to Y", "probably belongs to Y", an Open Question sent to another doc — with the doc it leaves and the doc it names.

Standing suspects — overlaps that recur by design, so check them every pass:

- The IP rules — `AGENTS.md`, `CONTRIBUTING.md`, `README.md` and `docs/decisions/licensing-and-ip.md` all carry them. The largest overlap in the repo, deliberate under the audience rule below, and therefore the most likely place for drift. Check they all agree, and that only one argues the case.
- Feel constants and the tuning Resource — `playtesting.md` against `AGENTS.md` and any design doc that names it
- The SWOS research against the design — every design section *Derived from* `sources/swos/` restates it, so values and rules there drift when either side is corrected

## 3. Find the owner and classify

Ownership follows the split in `AGENTS.md` → Where Things Live — the owner keeps the full statement and the reasoning, and is the tiebreak when copies disagree:

| Claim | Owner |
| --- | --- |
| Constraint that bounds every session | `AGENTS.md` |
| Settled choice, with its reasoning | `docs/decisions/` |
| What the game is or does | `docs/design/` |
| What the player is told | `docs/manual/`, once it exists |
| A decision you'd make at the keyboard | `ways-of-working/` |
| Where the work stands | `project/` |
| What a reference game does | `sources/` |

**Within a folder, the index decides.** Every system has one owning doc, per [`docs/README.md`](../../../docs/README.md) — the doc whose *What it covers* row takes in the claim. Other folders have their own index — their README, or for a reference game its `overview.md` — and it decides the same way. **A claim no row covers is a gap in the map**, and fixing it includes adding the claim to the owner's row — otherwise two docs whose rows are both vague can each defer it to the other.

Then classify each claim:

**Not a repeat.** One word in two senses — "shape" as a team's formation is not "shape" as a sprite's outline. Index rows in the folder READMEs restate titles and one-line summaries by design.

**Deliberate — keep it, check it.** Some docs must carry a rule inline for their reader:

- `AGENTS.md` loads every session, so the constraints and the pillars sit inline.
- `CONTRIBUTING.md` is the entry point for outside contributors, who never open `AGENTS.md`. A contributor has to see what gets rejected without chasing links.

The rule may repeat per audience; the argument may not — exactly one doc holds the reasoning and the rest defer to it, as `CONTRIBUTING.md` already does for Licensing and IP. These are the drift candidates: compare each copy against the owner and reconcile every difference in substance.

Two more pairs are meant to restate each other and need the same check, never a merge:

- `project/milestones/*.md` protocols against the session habits in `ways-of-working/playtesting.md`
- `sources/swos/` against design sections *Derived from* it. A finding about SWOS updates the *Derived from* side and never a section marked *Departs from SWOS*, per [Writing From SWOS](../../../ways-of-working/spec-chain.md#writing-from-swos)

**Redundant — consolidate it.** The same rule *argued twice*: two docs each explaining why, or each specifying the same behaviour independently.

**Misplaced — move it.** Stated once, in a doc that isn't its owner.

**Orphaned handoff — land it.** The doc a handoff names doesn't state the claim or hold the question, or hands it back. Neither side owns it until the map says which does.

## 4. Agree the decisions before editing

Do not edit yet. Put the judgement calls in front of the user in one block — this is the only approval point, so it has to carry everything that isn't mechanical:

- **Ownership** — each duplicated claim, the doc proposed to own it, and the docs that would lose it.
- **Moves** — each misplaced claim and orphaned handoff, the doc proposed to own it, and any index row that gains it.
- **Deletions** — every file proposed for deletion, with the index rows that go with it.
- **Drift** — each divergence, what the copies say, and which is proposed to win.
- **Escalations** — pairs with no clear owner, claims no row covers and no row plausibly could, or where both copies read as deliberate and disagree on substance rather than staleness. Check `git log -1 --format=%ai -- <file>` on each, report what you found, and ask. Never pick one silently.

Once agreed, apply all of it without prompting again. The cross-links, the removed restatements and the index rows are mechanical consequences of the decisions above — asking per edit wastes the review time this pass is meant to save.

## 5. Resolve

**Redundant claims.** Every doc but the owner drops the claim and links instead. State the rule, link the rationale — never restate it. The specific doc links to the general one, not the reverse. A placeholder whose entire content is covered elsewhere gets deleted, along with its index row — deleting beats leaving an empty file as a promise.

**Drifted claims.** Correct the copy to match the owner, and make sure the copy carries a link to it. That link is what makes the pair findable next time — every copy of a claim, kept or removed, should point at its owner.

**Misplaced claims and orphaned handoffs.** The owner states the claim, or holds the Open Question; the other doc links to it where its reader needs the pointer, and drops it otherwise. Add the claim to the owner's index row if the row doesn't already cover it. A move into a design doc changes a constraint — list the milestones linking either doc, per `AGENTS.md` → Conventions → *Downstream*.

`ways-of-working/spec-chain.md` was written to the cross-link rule — use it as the reference for how a link should read.

## 6. Report

The decisions were already agreed at step 4, so keep this short:

- What was applied, as a count per category and the list of files touched.
- **Anything that deviated** from what was agreed, and why — a claim that turned out to have a fourth copy, an owner that didn't fit once the edit was attempted. Call these out; they are the only part of the report that carries new information.
- Milestones a move may have put out of step with their design docs.
- Any escalation still unanswered.

Leave the tree uncommitted. The diff is the review.

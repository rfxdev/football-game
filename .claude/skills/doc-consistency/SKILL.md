---
name: doc-consistency
description: Keep the documentation set consistent. Finds every claim stated in more than one place, then either folds the redundant copies into a single owning doc or, where the repeat is deliberate, checks the copies still agree and reconciles them. Use for a duplication, drift or consolidation pass over the docs, after changing a rule that appears in several places, or before marking docs Reviewed.
---

# Documentation consistency pass

Two failure modes, one cause — a claim living in more than one file:

- **Redundancy.** It is stated twice and shouldn't be.
- **Drift.** It is stated twice for good reason, and the copies no longer agree.

Drift is the more dangerous of the two and the harder to spot: neither file looks wrong on its own. Both fall out of the same inventory, so find them in one pass.

Neither can be grepped — the second copy is rarely worded like the first. Read the whole set at once and work from claims.

An optional argument narrows the pass to one folder (`ways-of-working`, `docs`, `project`). No argument means everything.

## 1. Read everything

Start from a clean tree — `git status --short` should be empty of doc changes. The pass edits many files at once, so the diff is the review surface and `git checkout .` is the undo. If the tree is dirty, say so and stop.


```bash
find AGENTS.md CONTRIBUTING.md README.md docs ways-of-working project -name '*.md' | sort \
  | xargs -I{} sh -c 'printf "\n\n===== %s\n" {}; cat {}'
```

Read all of it before forming an opinion. Include the short files — a 15-word placeholder that restates a populated doc is redundancy, and deleting it is the cheapest fix available.

## 2. Inventory the claims

For every normative statement — a rule, a constraint, a rationale, a target — note the claim and **every** file that states it, not just the first two. Work from claims, not phrases: the same rule appears as prose in one doc and a bullet in another.

Standing suspects — overlaps that recur by design, so check them every pass:

- The IP rules — `AGENTS.md`, `CONTRIBUTING.md` and `docs/decisions/licensing-and-ip.md` all carry them. The largest overlap in the repo, deliberate under the audience rule below, and therefore the most likely place for drift. Check all three agree, and that only one argues the case.
- Feel constants and the tuning Resource — `playtesting.md` against `AGENTS.md` and the `design/match-engine/` docs that name it

## 3. Classify each repeat

**Not a repeat.** One word in two senses — "shape" in `formation-and-shape-system.md` is not "shape" in `visual-style-guide.md`. Index rows in `docs/README.md`, `ways-of-working/README.md` and `doc-review.md` restate titles and one-line summaries by design.

**Deliberate — keep it, check it.** Some docs must carry a rule inline for their reader:

- `AGENTS.md` loads every session, so the constraints and the pillars sit inline.
- `CONTRIBUTING.md` is the entry point for outside contributors, who never open `AGENTS.md`. A contributor has to see what gets rejected without chasing links.

The rule may repeat per audience; the argument may not — exactly one doc holds the reasoning and the rest defer to it, as `CONTRIBUTING.md` already does for Licensing and IP. These are the drift candidates: compare each copy against the owner and reconcile every difference in substance.

Two more pairs are meant to restate each other and need the same check, never a merge:

- `project/milestones/*.md` protocols against the session habits in `ways-of-working/playtesting.md`
- `project/doc-review.md` rows against the index in `docs/README.md`

**Redundant — consolidate it.** The same rule *argued twice*: two docs each explaining why, or each specifying the same behaviour independently.

## 4. Agree the decisions before editing

Do not edit yet. Ownership follows the split in `AGENTS.md` → Where Things Live — the owner keeps the full statement and the reasoning, and is the tiebreak when copies disagree:

| Claim | Owner |
| --- | --- |
| Constraint that bounds every session | `AGENTS.md` |
| Settled choice, with its reasoning | `docs/decisions/` |
| What the game is or does | `docs/design/` |
| What the player is told | `docs/manual/` |
| A decision you'd make at the keyboard | `ways-of-working/` |
| Where the work stands | `project/` |

Put the judgement calls in front of the user in one block — this is the only approval point, so it has to carry everything that isn't mechanical:

- **Ownership** — each duplicated claim, the doc proposed to own it, and the docs that would lose it.
- **Deletions** — every file proposed for deletion, with the index rows that go with it.
- **Drift** — each divergence, what the copies say, and which is proposed to win.
- **Escalations** — pairs with no clear owner, or where both copies read as deliberate and disagree on substance rather than staleness. Check `git log -1 --format=%ai -- <file>` on each, report what you found, and ask. Never pick one silently.

Once agreed, apply all of it without prompting again. The cross-links, the removed restatements and the `doc-review.md` updates are mechanical consequences of the decisions above — asking per edit wastes the review time this pass is meant to save.

## 5. Resolve

**Redundant claims.** Every doc but the owner drops the claim and links instead. State the rule, link the rationale — never restate it. The specific doc links to the general one, not the reverse. A placeholder whose entire content is covered elsewhere gets deleted, along with its rows in `docs/README.md` and `project/doc-review.md` — deleting beats leaving an empty file as a promise.

**Drifted claims.** Correct the copy to match the owner, and make sure the copy carries a link to it. That link is what makes the pair findable next time — every copy of a claim, kept or removed, should point at its owner.

`ways-of-working/spec-chain.md` was written to the cross-link rule — use it as the reference for how a link should read.

## 6. Update the tracker

If `project/doc-review.md` exists, update the Notes for every doc touched, and move a row to *Reviewed* only where the doc was read end to end and now has no known duplication. If that file has been deleted the review has ended — skip this step; the pass still works without it.

## 7. Report

The decisions were already agreed at step 4, so keep this short:

- What was applied, as a count per category and the list of files touched.
- **Anything that deviated** from what was agreed, and why — a claim that turned out to have a fourth copy, an owner that didn't fit once the edit was attempted. Call these out; they are the only part of the report that carries new information.
- Any escalation still unanswered.

Leave the tree uncommitted. The diff is the review.

---
name: doc-review
description: Review a documentation file for concision, focus, and actionability — cut prose that justifies itself down to the rules and decisions a reader needs, and structure the doc around what the reader has to act on. Spots content that belongs in another doc, and content deferred elsewhere that belongs here, and suggests where each goes. Length isn't the target; clarity is. Use whenever asked to review a doc, including mid-change, or when a doc is hard to act on — buried in self-justification, repetitive, unclear about what the reader should actually do, or holding content that seems to be in the wrong place.
---

# Documentation review

Success is a reader finishing the doc knowing what to do, without wading through the case for it. That can be 100 words or 1,000 — length follows from what the content actually needs, not the other way around. Don't chase a smaller word count or fewer lines. This works on one doc and can run mid-change. It spots content in the wrong place and suggests where it goes; [doc-consistency](../doc-consistency/SKILL.md) works across the whole set once a change has landed, and settles ownership there.

Three review gates, each smaller than the last: agree the purpose, agree the section titles, then agree each section as it's drafted. Never present the whole rewritten doc as one block to review — that wall of text is exactly what this process exists to avoid.

## 1. Work out the purpose — gate 1

Read the current doc fully, then set it aside as an editing target, not a scaffold. Work out: who reads this, what they need to walk away able to do, and what they actually require to get there. State that purpose in a sentence or two and check it with the user before going further — everything downstream inherits whatever gets agreed here.

Start from the doc's row in its folder's index — [`docs/README.md`](../../../docs/README.md) for `docs/`, each other folder's README for its own, or `overview.md` for a reference game in `sources/`. If the agreed purpose differs from the row, the row changes with it: it's the map placement is judged against, here and in doc-consistency. Read the rows of the docs next to it too — gate 3 needs them to say where content belongs.

## 2. Propose section titles — gate 2

List candidate section headers, each with a one-line description of what it covers and, briefly, what existing content isn't making the cut. Check this list with the user before drafting any prose — restructuring a list of headers is cheap; restructuring finished prose isn't.

Order and shape follow `AGENTS.md` → Conventions. For a design doc, also check against The Spec Chain → *Turning It Into Design* and *Writing From SWOS*, in `ways-of-working/spec-chain.md`.

## 3. Fill in one section at a time — a gate per section

Draft one section, then stop and show just that section before starting the next. For each existing paragraph that might belong in it, classify it:

- **Justification** — argues for a decision, compares alternatives, defends against an objection nobody's raising. Doesn't make the cut, or survives as one clause.
- **Actionable content** — a rule, limit, checklist, or reference the reader needs to act correctly. Candidate to keep, shaped however is easiest to scan — bullets, headers, tables.
- **Out of scope** — fits another doc's row in the index better than this doc's purpose. Doesn't stay; goes to step 6 with that doc as its suggested home.
- **Wrongly deferred** — a handoff ("X is Y's", "belongs to Y", an Open Question sent to Y) where X fits this doc's purpose, or where Y doesn't take X on. Open Y to check. If X fits here, pull it back and note Y's matching change for step 6; if it fits neither, it goes to step 6 as an orphan.

`docs/decisions/` is where reasoning is meant to live (`AGENTS.md` → Where Things Live) — its sections can keep one line of "why" for a choice that could plausibly be revisited, but not the case for a settled one.

Work through the section list from gate 2 in order, one gate per section. Don't batch two or more sections into a single review.

## 4. Assemble and reread cold

Once every section is agreed, assemble the full doc and read it once more end to end — sections approved in isolation can still misalign with each other (repeated framing, an inconsistent term, a transition that no longer makes sense). Fix what surfaces here without reopening the per-section gates unless the fix is substantial.

## 5. Report

Report briefly — lead with what's now clearer or easier to act on.

## 6. Follow-on: what left this doc

Once the rewrite is settled, compile everything from the old version that isn't in the new one — deferred items, open questions, asides dropped along the way, content marked out of scope, and the other side of any handoff gate 3 changed. For each, check the index for a suggested owner and whether that owner already states it. Bring the list to the user as one consolidated decision — keep, move, or drop, per item, with any index row or other doc that changes with it — rather than deciding unilaterally.

Suggest; don't edit other docs here. Once the change lands, doc-consistency confirms the owner across the whole set.
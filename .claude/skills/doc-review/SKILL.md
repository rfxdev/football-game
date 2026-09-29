---
name: doc-review
description: Review a documentation file for concision, focus, and actionability — cut prose that justifies itself down to the rules and decisions a reader needs, and structure the doc around what the reader has to act on. Length isn't the target; clarity is. Use whenever asked to review a doc, or when a doc is hard to act on — buried in self-justification, repetitive, or unclear about what the reader should actually do.
---

# Documentation review

Success is a reader finishing the doc knowing what to do, without wading through the case for it. That can be 100 words or 1,000 — length follows from what the content actually needs, not the other way around. Don't chase a smaller word count or fewer lines. This complements [doc-consistency](../doc-consistency/SKILL.md), which removes duplication across docs — run this after that, on one doc at a time.

Three review gates, each smaller than the last: agree the purpose, agree the section titles, then agree each section as it's drafted. Never present the whole rewritten doc as one block to review — that wall of text is exactly what this process exists to avoid.

## 1. Work out the purpose — gate 1

Read the current doc fully, then set it aside as an editing target, not a scaffold. Work out: who reads this, what they need to walk away able to do, and what they actually require to get there. State that purpose in a sentence or two and check it with the user before going further — everything downstream inherits whatever gets agreed here.

## 2. Propose section titles — gate 2

List candidate section headers, each with a one-line description of what it covers and, briefly, what existing content isn't making the cut. Check this list with the user before drafting any prose — restructuring a list of headers is cheap; restructuring finished prose isn't.

## 3. Fill in one section at a time — a gate per section

Draft one section, then stop and show just that section before starting the next. For each existing paragraph that might belong in it, classify it:

- **Justification** — argues for a decision, compares alternatives, defends against an objection nobody's raising. Doesn't make the cut, or survives as one clause.
- **Actionable content** — a rule, limit, checklist, or reference the reader needs to act correctly. Candidate to keep, shaped however is easiest to scan — bullets, headers, tables.

`docs/decisions/` is where reasoning is meant to live (`AGENTS.md` → Where Things Live) — its sections can keep one line of "why" for a choice that could plausibly be revisited, but not the case for a settled one.

Work through the section list from gate 2 in order, one gate per section. Don't batch two or more sections into a single review.

## 4. Assemble and reread cold

Once every section is agreed, assemble the full doc and read it once more end to end — sections approved in isolation can still misalign with each other (repeated framing, an inconsistent term, a transition that no longer makes sense). Fix what surfaces here without reopening the per-section gates unless the fix is substantial.

## 5. Report

Report briefly — lead with what's now clearer or easier to act on.

## 6. Follow-on: audit what didn't make the cut

Once the rewrite is settled, compile everything from the old version that isn't in the new one and has no obvious owner elsewhere in the doc set — deferred items, open questions, asides dropped along the way. Check each against the rest of the doc set for an existing home first. Bring what's left to the user as one consolidated decision — keep, move, or drop, per item — rather than deciding unilaterally.
# The Spec Chain

How something becomes work, and how it is held to what was written — how a proposal arrives, what it is checked against, what gets written before any of it is built, and what happens when playtesting says the writing was wrong.

The standard flow is **manual → design → code**. What the player is told is settled first, the design delivers it, the code implements the design. Writing the manual entry first is what forces a proposal to be concrete enough to argue with.

## Three Routes In

Not everything originates in the manual. The route decides what gets written and in what order.

| Route | Path | Examples |
| --- | --- | --- |
| **Told** — the player is instructed | Manual entry → design → code | Movement, passing, shooting, what a button does in a given context, what a screen means |
| **Felt** — the player perceives it but is never told | Design → code. No manual entry | Ball bounce, friction, turning radius, shot power curve, AI positioning |
| **Neither** — invisible scaffolding | Justified against a milestone → code | Input Map, test suites, build pipeline, sandbox scene |

- The split is *told* versus *felt*, not visible versus invisible. The player certainly notices whether the ball is lively or dead; they are just never told about it in words, so it gets a design doc and no manual entry

## The Gate

Checked before anything is written:

- Against the design pillars in [Game Vision and Design Goals](../docs/design/game-vision-and-design-goals.md)
- Against the [Player Manual](../docs/manual/player-manual.md)'s controls section, for anything on the *told* route. Single-button input means every action competes for the same button in some context, so that table is the scarcest resource in the project — a proposal needing a new input, or a new context-sensitive meaning for an existing one, declares that cost here rather than at implementation
- Against [Licensing and IP](../docs/decisions/licensing-and-ip.md) where content is involved
- Against the systems it interlocks with, per the vision's [Scope & Boundaries](../docs/design/game-vision-and-design-goals.md#scope--boundaries): what's automatic, what the player controls, and whether it gets ahead of the systems it touches

If a *told* proposal can't be written as a sentence a player would understand, it isn't ready, and it may not belong.

## Writing From SWOS

Until the clone plays, most of what the manual and design say comes from [the SWOS research](../sources/swos/). It is an input to writing them, never the spec.

- **Restate it in our words and our units.** A speed in SWOS pixels per tick becomes a number in world units; a formula becomes the mechanism the design doc describes. Once written, the doc is what a milestone is judged against, not `sources/`
- **Convert ticks by real time, from the Amiga's 50 a second** — the [reference pace](../docs/decisions/architecture-and-stack.md). Into our 60: a per-tick speed × 50/60, a frame count × 60/50, and anything that changes a speed every tick — an acceleration, a deceleration like the tackle lunge's — × (50/60)². Scaling that last one like a speed leaves the lunge too short in both time and distance. Check the value against the Amiga disassembly first; most of the research cites DOS, and some values differ between the two
- **A count from the per-team update is two ticks.** The reference updates each team every other tick, so a timer counted down there runs at half the tick rate — double it before converting. See *Engine Performance* in [Match Mechanics](../sources/swos/match-mechanics.md)
- **A tick pattern is kept, not rescaled.** Ball control's two ticks on, two off stays two and two at 60, running a little faster in real time — close enough to play the same, where a rescaled pattern can't land on whole ticks
- **Record where it came from.** A *Derived from* line under each section that inherits from SWOS, naming the `sources/swos/` section. It is what makes a later departure read as a decision rather than as drift
- **Mark a departure where it lands.** A *Departs from SWOS* line under the section, beside its *Derived from*: what SWOS does, what we do instead, and why or where it was decided. Checking a section against the disassembly then finds the difference already explained, and doesn't "fix" it back
- **Where SWOS is silent, it's ordinary design** — mechanism and criteria written as below, judged by playing
- **Past the clone, `sources/` is research only.** A proposal can cite it; nothing is checked against it

## Writing the Manual Entry

- Present tense, player voice, as if the game already exists: *"Hold the button longer to hit it harder."*
- No hedging and no rationale. Being unable to hedge is what makes it a spec rather than a wish; the reasoning belongs in the design doc
- **Per milestone, not up front.** A milestone's section is written before that milestone is built, not before the first one. A complete manual written today would be fiction about a game nobody has played, and its most confident passages would cover the milestones furthest away

## Turning It Into Design

The manual sentence says *what happens*. The design says *by what mechanism, in which system*, and *how you'll know it's right* — written before code, not reconstructed from it.

- **Name the owning doc.** Every manual sentence lands in exactly one system in the [design set](../docs/README.md). Deciding which one here is the point; discovering it at implementation is how a mechanism ends up spread across three files
- **Acceptance criteria go in the same doc, in the same sitting.** How it works and how you'll know it's right are two halves of one spec, not two documents — and you can't state a target before you know what it's a target for. Sometimes the criterion is correctness (*the shadow tracks the ball's height*), sometimes a range judged by playing (*a short pass arrives in under 0.5 seconds, weighted rather than instant*). Same section either way
- **Intent and number are both load-bearing.** *"Passing should feel snappy — the ball reaches its target in under 0.5 seconds for a short pass. Weighted, not instant."* An adjective alone can't be missed by a build, so it never fires; a number alone tells you nothing about what to do when it's met and the thing still feels wrong. Together they convert "hmm, not quite right" into "it says under 0.5s and it's arriving at 0.9s" — something you can act on, disagree with, or revise
- **The value itself lives in the tuning Resource, not in the prose.** The doc states the target and its range; where the number lives and how it gets tuned is [Playtesting](playtesting.md), and what pins it afterwards is [Automation Testing](automation-testing.md)
- **Where two systems have to agree, say so in both.** A shared constant or a shared predicate is exactly where the design set drifts, and a cross-link written now is cheaper than finding the disagreement in play
- **Anything still undecided goes in that doc's Open Questions.** Unwritten decisions get made by whoever writes the code first, silently and without the reasoning recorded

Not everything reaching design came from the manual: *felt* proposals start here and are all mechanism and criteria, and *neither* proposals skip design entirely.

## When It Doesn't Feel Right

**First: is it broken, or is it wrong?** The rungs below all assume the code does what the design says. A bug is a bug — fix it and re-judge, per the fun-versus-bugs split in [Playtesting](playtesting.md). Climbing the chain to explain a defect retunes a mechanism that was never actually tried.

Past that, playtesting feeds back up the chain, and the chain has rungs. Take the lowest one that fixes it:

1. **Tuning value** — mechanism right, number wrong. Retune live, per [Playtesting](playtesting.md). Not for a value the design doc fixes: changing that is rung 2. One *Derived from* SWOS also departs from the clone, which the [Roadmap](../project/roadmap.md) holds until the clone plays
2. **Design** — the number does what the doc asked for and it still isn't right. Either the criteria asked for the wrong thing or the mechanism can't deliver them; which of the two it is only becomes clear once you're in the doc, so it's one visit and not two
3. **Manual** — the promise itself was wrong

Almost everything is rungs 1 and 2. Before touching the manual, ask: **is the promise wrong, or is the delivery wrong?** Reaching for rung 3 first erodes the spec to fix problems that were really design problems.

## Changing the Manual

Playtesting can overturn the manual — that is the point of the loop. But a manual that yields on contact stops being a spec and becomes a transcript of whatever the code happens to do.

- A manual change is a **design decision, not a bug fix**. Record it in `docs/decisions/`: what the manual said, what playtesting showed, what it says now
- Three lines is enough. The cost is deliberate, and it is what keeps the manual worth writing first
- Without it the drift is the same one written criteria protect against for tuning values: every change locally reasonable, and twenty sessions later the game is somewhere nobody chose

## Not Yet Scheduled

Anything not on the [Roadmap](../project/roadmap.md) is in [Ideas](../project/ideas.md), unchecked. The gate runs when an idea is scheduled, not before: which dimension deepens first can't be decided until the systems around it are known.

## Declined

Record what was turned away and why, in `docs/decisions/`. Cheap to write once, and it stops the same proposal arriving a third time with nothing to point at.

## Open Questions

- **What keeps the design set true once code exists.** The rungs above are triggered by feel, so they catch nothing when a refactor quietly changes a mechanism the design doc still describes the old way. Revisit at the first milestone with real code, against an actual instance rather than a predicted one

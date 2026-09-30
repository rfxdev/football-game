# Automation Testing

Scope: automated checks that run without a human at the controls. The human-in-the-loop side — running the game in-editor and judging it by feel — is [Playtesting](playtesting.md), and it's the primary loop for the feel-first milestones in [Roadmap](../project/roadmap.md).

This doc is the rationale and the rules: what earns a test, what doesn't, the tooling, and the constraints that make automated match testing possible at all. What actually gets tested, milestone by milestone, lives with each milestone in [`project/milestones/`](../project/milestones/) alongside the feature it tests — coverage follows the build order, not the design set: a system gets tests when it's built, not when it's described.

## What a Test Has to Earn

A test costs its writing plus every future edit that keeps it passing. It earns that back only when the failure it catches is one playtesting would miss, or find far too late. Write it when the failure is:

- **Silent** — nothing looks wrong. Fake-Z arithmetic drifting, a shadow offset subtly out. The game sits on numbers nobody can eyeball
- **Rare** — reproducing it needs deliberate set-up. A ball leaving play exactly on a corner; a shot crossing the line at bar height
- **Expensive** — a crash, a soft-lock, a match that can't finish
- **Exhaustive** — every boundary of a predicate checked, which no amount of playing does

Don't write it when:

- Playtesting fails loudly and immediately on it — the player doesn't move, the ball doesn't spawn
- It asserts an exact value that legitimate tuning will change — see Threshold Tests. A value the design doc fixes isn't one — see Fixed-Value Tests
- It restates the implementation. If changing the code always means changing the test, the test knows nothing the code doesn't
- It asserts the engine's behaviour, not the project's — a Godot built-in, Input Map clamping, a deadzone, the physics server. That belongs to Godot's suite
- What's under test is configuration, not code — a project setting, or a resource with no logic around it. There's nothing to assert
- It's visual or audio. Judged by eye and ear; tooling to do otherwise costs more than it returns

## Tooling

- **GdUnit4** — embedded unit/integration testing for GDScript, chosen with the engine in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md)
- **gdlint** (godot-gdscript-toolkit) — style linting, CLI-driven so it can run in CI
- **Typed GDScript** — first line of defence and free. A coding habit rather than a tool, but it counts as part of the net

## Invariants

A shared per-tick check, run under every scenario and simulation test rather than restated per test — the assertions a match must never violate regardless of what's actually being tested for. High leverage because they run for free with every other test and catch the class of bug nobody was specifically looking for — a possession count that's briefly two, a position that's gone NaN. What's actually checked is scenario-specific and grows with the milestone that introduces it, in [`project/milestones/`](../project/milestones/).

## 360 Testing

A milestone can only test what already exists. It tests its own deliverable and has no way to know what a later milestone will make possible, so it shouldn't try to guess. But that later milestone, once built, is exactly positioned to look back and ask what it just made testable about the ones before it — 3.2 Shape and Home Zones asserting a floor on 3.1 Dumb Five a Side's blobbing is the shape of it.

- **Each milestone's Testing field looks at its own deliverable only.** Its 360 Testing field looks backward: given what this milestone just added, what can now be asserted about an *earlier* milestone's deliverable that couldn't be before?
- Covers widening too — not only brand-new assertions, but an existing test whose assumptions no longer hold now the game is bigger than it was when that test was written
- This is the deliberate version of what [Invariants](#invariants) already do informally: coverage growing milestone by milestone. Naming it as its own field is what stops it from being caught by luck rather than by habit

## Determinism

Fixed seed plus fixed inputs must produce the same result twice, or nothing above is trustworthy. The engine-level constraints that make this possible — simulation logic confined to `_physics_process`, clock and RNG injected rather than read from a global — are decisions, not testing habits, and live in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md).

- A test that runs the same seed twice and compares world state is cheap, and the day it fails it has found something poisoning every other test

The payoff — building a whole match headless and stepping it a fixed number of ticks — isn't needed until there's a whole match to step. The constraint above is needed from the first line of simulation code.

## Threshold Tests

Feel turned into something testable: not "does this feel good" but "does a 10-metre pass arrive in 0.3–0.7 seconds". The design doc's acceptance criteria give the range; the test guards it — see [The Spec Chain](spec-chain.md).

- **Ranges, never point values.** A point value is a tuning lock that fails on every legitimate adjustment; a range only fires when something has genuinely left the intended character
- **Added *after* a mechanic feels right, not before.** Written early they'd pin values that haven't been found yet, making iteration slower rather than safer. Written after, they catch a later change — tick rate, a friction tweak, a new collision shape — dragging feel out of character without anyone noticing
- **Only feel tests wait.** Ordinary correctness tests for the same systems belong from day one, because they ask whether the thing works, not whether it's any good
- **A retune that leaves the range goes through the design doc.** The range is the doc's acceptance criterion, so a value that wants to sit outside it is rung 2 in [The Spec Chain](spec-chain.md#when-it-doesnt-feel-right): revise the criterion with its reason, and the test follows. Widening the test on its own is how ranges come to mean nothing
- Which is the resolution to the obvious objection: feel isn't untestable, *exact values still being tuned* are

## Fixed-Value Tests

A design doc can fix a number rather than a range — a top speed, the frames a tackler spends on the ground, the pitch's dimensions — whether *Derived from* SWOS per [Writing From SWOS](spec-chain.md#writing-from-swos) or decided outright. The threshold rules exist to leave room for tuning, and a fixed value isn't tuned, so they don't apply:

- **Exact, not a range** — the number the design doc states, to the tick; positions to a float tolerance, not a looser band. Determinism is what makes that possible
- **Written with the mechanic, not after it feels right.** There's no value left to find, so this is a correctness test: does the build do what the doc says
- **Assert the behaviour, not the Resource.** Reading the tuning value back is testing configuration. Drive the mechanic and measure what it does — ticks to cover a distance, frames spent down
- **Most earn their place.** A fixed number is the silent kind: a few percent off looks right and plays wrong against everything calibrated alongside it
- **It changes when the design doc does, and not otherwise.** A failure is a bug, or a departure that hasn't been through rung 2

## CI

- Not set up, and it earns nothing while the suite runs in seconds in the editor. The trigger is running it locally becoming something you skip
- GdUnit4 emits JUnit XML and has a GitHub Actions integration, so the path is known. Target when it comes: lint plus unit tests on push, longer simulation runs on a slower cadence
- **Filename case consistency is the one check worth having before any of that** — it catches `res://` paths that work on the case-insensitive Mac filesystem and break on the Deck. Owned by [Build Pipeline](build-pipeline.md); any Linux runner catches it for free simply by loading the project

## Open Questions

- At which milestone does CI start earning its keep? The trigger above is a heuristic, not an answer
- Same headless Godot command on macOS locally and Linux in CI, or divergent setup?

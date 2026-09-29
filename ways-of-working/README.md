# Ways of Working

How the work happens — the loops, habits and checks. `docs/` holds what the game *is*; this folder holds how it gets built. [Contributing](../CONTRIBUTING.md) is the outward-facing version.

Solo hobby project, worked kanban-style — one item pulled at a time, as time allows. This folder records decisions and hazards, not routines. Something written down once is written down; it doesn't also need a checklist prompting someone to read it. Process that exists to keep a team honest is overhead for one person.

## The Loop

Listed in the order they run, and worth reading that way first time.

| Document | What it covers |
| --- | --- |
| [The Spec Chain](spec-chain.md) | How something becomes work and how it is held to what was written. Manual → design → code, the three routes in, the gate, and the rungs back up when playtesting disagrees |
| [Playtesting](playtesting.md) | Judging the game by playing it. Tuning runs and milestone sessions, the sandbox scene, live tuning, debug visualisation, session habits |
| [Automation Testing](automation-testing.md) | Checks that run without a human at the controls. What earns a test, invariants, determinism, threshold-test rules |

**manual entry → design, with its acceptance criteria → build → tune live → playtest against those criteria → encode as tests.** It is a loop, not a line — playtesting feeds back up it, as far as the manual when the promise itself was wrong. What each milestone's session is asking sits with the milestone itself, in [`project/milestones/`](../project/milestones/). The Spec Chain owns both ends: what has to be written before code, and what overturns what afterwards.

## The Platform Underneath

Not stages of the loop — reference, returned to with a specific question. Trustworthy input comes first: feel can't be judged through a controller you don't trust.

| Document | What it covers |
| --- | --- |
| [Gamepad Input and Steam Deck Parity](gamepad-input-and-steam-deck-parity.md) | The 8BitDo as a Deck stand-in, and what makes it trustworthy |
| [Build Pipeline](build-pipeline.md) | MacBook to Steam Deck |

## Process Notes

- **This folder holds rationale, not content.** Each doc states a generic principle and why it holds — the rule, not an instance of it. A specific value, schedule, or milestone-by-milestone plan belongs to whatever owns that content instead: [`project/milestones/`](../project/milestones/) for what's tested, tuned, or verified when; a design doc for a specific number. A doc here that starts listing per-milestone specifics has drifted into content, and the specifics want moving out, not writing up
- **The unit of process is the item, not the session.** No sprints, no cadence, no start- or end-of-session ritual
- **Docs get a consistency pass after they change**, not on a schedule. `/doc-consistency` reads the whole set and finds claims that are duplicated, or that repeat by design and have drifted apart — worth running after a documentation update, large or small. The procedure lives in the skill, not in a doc here

# Playtesting

Judging the game by playing it. [Automation Testing](automation-testing.md) tells you whether the game is correct; this tells you whether it's any good — the thing the feel-first sequencing in [Roadmap](../project/roadmap.md) exists to protect, and how the "fun over realism" pillar gets validated.

Two modes, and conflating them is how a session stops meaning anything:

- **The tuning run** — short, constant, in-editor. Change a value, run it, feel the difference, change it again. Nothing is logged and nothing is held still; the point is speed.
- **The milestone session** — time-boxed, deliberate, and you change *nothing* while it runs. What each one is asking sits with its milestone in [`project/milestones/`](../project/milestones/). This is the one that gets logged.

Most of what follows is the apparatus that makes both cheap, because the cost of judging feel is what decides how often you do it. The principle underneath: **never build to test something the editor can show you.** Builds are platform checks, triggered at phase boundaries — see [Build Pipeline](build-pipeline.md).

## In-Editor Play Is the Primary Loop

- Run Current Scene (F6) rather than Run Project (F5) while mechanics are in flux — it launches whatever scene is open without touching the project's configured main scene, so there's no switching cost between the sandbox and the full match
- GDScript reloads on save. For logic-only changes, saving and re-running is close to instant
- No Play Mode configuration step is needed. Each run launches a fresh process, so static state starts clean every time

## Sandbox Scene

- Keep a dedicated stripped-down scene — flat pitch, two players, one ball — separate from the full match scene. Suggested: `scenes/sandbox/sandbox.tscn`
- The point is isolation: when the ball feels wrong, a sandbox tells you it's the ball. A full match scene with AI, formations and a state machine running does not
- Worth keeping the sandbox alive after [0.2 Sandbox Scene](../project/milestones/0.2-sandbox-scene.md) rather than deleting it. Every later system gets tuned in it too

## Live Tuning While Running

**If a value affects feel, it doesn't belong as a literal in a script.** Values buried in code don't get tuned, because tuning them costs a code edit and a restart — and the fourth variation you never tried is usually the good one.

- Mark tuning values (`friction`, `bounce`, `max_speed`, `shot_power`) as `@export`, then edit them from the Debugger → **Remote** tab while the game runs. It shows the live scene tree; changes to a selected node's exported properties take effect immediately, so tuning happens against a moving ball rather than by stop-edit-restart
- **Remote edits are not persisted back to the scene file.** Once a value feels right, write it in deliberately or it's gone on next run
- Longer term, a tuning Resource (`.tres`) beats scattered exports — one place to version, diff and swap presets, and plain text, so a session's change reads as a git diff

## Debug Visualisation

- Debug → **Visible Collision Shapes** should be on by default during match engine work. Ball/player interaction bugs are usually shape or offset bugs, and they're near-impossible to reason about invisibly
- The editor's Monitors tab (FPS, physics frame time, draw calls) is the cheap early-warning signal — worth glancing at rather than waiting for the Steam Deck to tell you
- Custom debug overlays (drawing AI target positions, decision states, pass lanes) will earn their keep once [Team AI and Decision Making](../docs/design/match-engine/team-ai-and-decision-making.md) starts. Cheap to add, and AI behaviour is otherwise judged by vibes alone

## What a Session Asks

A milestone's *Asking* and *Session shape* fields.

- **One variable — the one this milestone isolates.** A question that could have been asked at the previous milestone belongs to that one
- **Answerable no.** "Does it feel good?" can't fail. Name the failure mode, and its opposite where there is one, so the session can come back with either
- **Shape follows the question.** Length, solo or with someone, structured or free play — chosen by what the question needs. A second player earns their place when the thing being judged is something the solo player has stopped noticing

## Session Habits

These govern the milestone session, whatever it is asking. The logging and the A/B rule carry back to tuning runs too — without them a run tells you the game feels different, not which change did it.

- **Keep a playtest log** — plain text in the repo, one entry per session, newest first. Date, what was tested, what felt wrong, what felt good. This is the subjective counterpart to CI output: the record of how the game has felt over time, which memory reconstructs badly and optimistically. The file gets created when the first milestone that needs one makes it real; its shape and location are a decision for that point, not now
- **Log the tuning values before and after.** The tuning Resource is plain text, so a session's change is a readable git diff — paste it into the log rather than transcribing it by hand and mistyping it
- **Judge feel on the controller, not the keyboard.** Keyboard input is digital and will flatter movement tuning that feels wrong on an analog stick. Setup and Deck parity are in [Gamepad Input and Steam Deck Parity](gamepad-input-and-steam-deck-parity.md)
- **A/B: never change more than one feel variable per session.** Play a session and log the numbers, change one value, play another session, compare the two entries. With two variables changed you learn that the combination feels different, not which one did it — and they may well be pulling against each other, so the pair can read as "no change" while both are wrong. This is slower than it feels like it should be, and it is the only thing that reliably works
- **Separate "fun" feedback from "bugs".** Fun is design; bugs are engineering. They want different responses and different urgency, and mixing them means design feedback gets triaged like defects — quietly deprioritised because nothing is visibly broken
- **Record sessions** (macOS screen recording, Cmd+Shift+5) so you can review decisions made under play pressure. You cannot introspect and play well at the same time; the recording is where "why did I do that?" gets answered
- Recordings are large and shouldn't be committed — see the ignore entry for `recordings/`

## Open Questions

- Does the sandbox scene stay one scene, or split per-system (ball sandbox, AI sandbox, set-piece sandbox) as the engine grows?
- One central tuning Resource, or one per system? Central is easier to diff and swap as presets; per-system keeps ownership clear as the engine grows
- Cadence: is a playtest every working session, or only at milestone boundaries? The per-milestone protocols in [`project/milestones/`](../project/milestones/) say what to test, not how often
- How long are recordings kept, and is there any point reviewing old ones once a milestone has passed?

# Technical Architecture and Stack

Engine: Godot 4.x (latest stable)

Primary language: GDScript — Godot's native scripting language, chosen for simpler syntax, faster iteration (no compile step), and best-supported tooling/documentation. C# remains an option for performance-critical code later if needed, not the starting point. GDScript drives all game logic and behaviour (AI, movement, state machines), not just visuals — rendering/animation is handled separately via the engine's own systems.

IDE: Godot's built-in editor, used editor-first for both scenes and scripting. Rider (available via existing JetBrains licence) is a known fallback if the built-in editor's limitations become blocking — not set up pre-emptively.

AI-assisted development: Claude Code, used directly against .gd/.tscn files without MCP initially. A Godot MCP server is a known option for later if context-sharing friction becomes a real cost. Neither approach currently lets Claude run the game and self-correct from results.

Testing framework: GdUnit4 — embedded unit testing for GDScript (and C# if needed later), with CI/CD support (JUnit XML, GitHub Actions integration) for when a build pipeline is set up.

Linting & type checking: GDScript supports opt-in static typing natively (type hints on variables/functions), checked by the editor/parser as you write — this is adopted as a coding habit rather than an external tool. gdlint (part of godot-gdscript-toolkit) is used for style/best-practice linting, with CLI support for CI. A newer class of GDScript-specific static analyzers (e.g. code-quality-focused tools that flag missing type hints, high complexity, magic numbers) exists and is worth reassessing later, particularly given potential benefits for reducing AI agent token usage on a larger codebase.

Development machines: Windows and macOS (MacBook Air M5) — dev loop only, not distribution. No code signing/notarisation required.

Distribution platforms: Windows, macOS, Steam Deck (Linux) — Godot supports native export to all three. Signed/notarised macOS builds are a future concern only if distributing to others.

Display targets: Steam Deck (1280×800, 16:10) is preferred, with standard laptop and monitor configurations (16:9) equally supported. Ultrawide is explicitly not a target: a pitch stretched that wide doesn't read well. What each display shows — how much pitch, the aspect band and the bars beyond it, and why the differences are fine — is [Camera](../design/match-engine/camera.md)'s, and pixel sharpness [Sprites](../design/match-engine/sprites.md)'s; this section is the settings that deliver it.

**One world unit is one pixel of the reference.** SWOS quotes its speeds and distances in its own pixels, so they copy straight across, converted only for tick rate per [Writing From SWOS](../../ways-of-working/spec-chain.md#writing-from-swos).

The view, in Project Settings → Display → Window:

- **Base viewport 426×266**, in world units — the Deck's 1280×800 at a scale of 3, rounded down. 1280×800 holds 426⅔ × 266⅔, so anything larger drops the Deck to a scale of 2
- **Fullscreen by default in exported builds**, at the display's own resolution; windowed is the player's option. Running from the editor stays windowed, so the setting is limited to exports — a feature-tag override or a startup check
- **Window size override 1280×800**, so a windowed build — the editor's included — opens at the Deck's view
- **Minimum window 1280×720**, so no window drops below a scale of 2 — the smallest display supported, fullscreen on a 720p screen, and what bounds how wide any view gets. Project Settings has no minimum, so it is set in code (`Window.min_size`) at startup
- **Stretch mode `canvas_items`, aspect `expand`, scale mode `integer`.** Integer mode rounds the scale down, so a display never sees less than the base area. `keep` letterboxes unconditionally; `expand` adds no bars
- **`expand` alone does not clamp**, so the 16:9 width cap and the bars beyond it need implementing rather than configuring

Input: one code path for desk and Deck. Godot normalises every pad onto an Xbox-style layout through SDL's game controller database, the same layer the Deck uses, so parity comes from not undermining that rather than from building anything. Setup and the habits that keep it true are in [Deck Input Parity](../../ways-of-working/deck-input-parity.md).

- **Game code reads named actions, never a device.** Keyboard and gamepad bind to the same actions, and nothing branches on input device or keys off the device name — under Steam Input that name may be a synthetic pad's
- **One prompt set: Xbox glyphs** (A/B/X/Y, LB/RB, LT/RT). Correct on the Deck, on the dev controller and for most PC players — no controller-family detection
- **No custom Steam Input profiles for now.** A distribution-time concern; Xbox-layout bindings are what the default profile expects, so it should map straight through

Physics tick rate: held at 60 ticks/second. It is a feel-critical constant — changing it changes how the ball behaves — so it is set once and treated as fixed rather than tuned, and it is a determinism requirement for headless match simulation — see [Automation Testing](../../ways-of-working/automation-testing.md).

Reference pace: SWOS is cloned at the Amiga's 50 ticks/second, the pace it was designed at. The DOS version's 70 is treated as a porting bug — it runs the Amiga's per-tick numbers on a 70 Hz display, so plays about 40% fast. Where the two versions' values differ, the Amiga's are the reference — see *Engine Performance* in [Match Mechanics](../../sources/swos/match-mechanics.md).

Determinism: simulation logic runs in `_physics_process`, never `_process` — `_process` runs once per rendered frame at a rate that varies with load and display, so anything affecting a match outcome from there is non-reproducible by construction. Elapsed time and randomness are injected — a tick-derived clock and a seeded RNG instance — never read from a global; unseeded `randf()` calls and wall-clock reads are what quietly make headless simulation non-reproducible. Decided once here and honoured as systems are built rather than retrofitted, because this is what makes the same seed plus the same inputs produce the same match twice — see [Automation Testing](../../ways-of-working/automation-testing.md) for what that buys.

Saves: the format is versioned from the first save, and every later format change ships a forward migration that runs on load. A career spans months of real time and the game will be updated inside that window, so a new attribute can't brick an old save; the version is near-free to add now and near-impossible to retrofit once saves worth keeping exist. Writes never overwrite the only good copy — write to a temporary file, then swap it in, keeping the previous save until the new one is complete. Steam Deck suspend and resume make an interrupted write routine rather than an edge case. If saves are held in a database, queries that feed simulation carry an explicit `ORDER BY`: unordered results break the reproducibility above. The storage technology itself is not yet decided.

## Why Godot over Unity

Unity was seriously evaluated as an alternative and rejected. The deciding factor was build friction for the primary target platform — Steam Deck (Linux native) — which is near-zero in Godot versus meaningfully more effort in Unity.

This was a deliberate trade-off, made with the costs understood rather than overlooked: at the time of the decision, Unity offered a more mature automated testing story and first-class C# support, while Godot's testing ecosystem was weaker (community-addon based) and C# support was second-class to GDScript. Both of these costs have since been mitigated in practice — GdUnit4 provides a solid CI-ready testing framework, and GDScript's typed, fast-iteration workflow has offset the appeal of C#'s ecosystem for this project's scope.

Secondary factors reinforcing the decision: Godot's 2D pipeline is native rather than bolted on, its gamepad input (Input Map) is simpler to configure than Unity's Input System, and it uses SDL2 across platforms including Linux — the same layer Steam Deck uses — giving high input parity between the macOS dev loop and the Deck. Godot is also open source, which fits the project's own non-profit/open-source ethos.

The rough heuristic used to decide: start in Godot if the game and the experience of making it matters most; start in Unity if engineering rigour and testability matter most. This project prioritised the former.
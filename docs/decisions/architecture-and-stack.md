# Technical Architecture and Stack

Engine: Godot 4.x (latest stable)

Primary language: GDScript — Godot's native scripting language, chosen for simpler syntax, faster iteration (no compile step), and best-supported tooling/documentation. C# remains an option for performance-critical code later if needed, not the starting point. GDScript drives all game logic and behaviour (AI, movement, state machines), not just visuals — rendering/animation is handled separately via the engine's own systems.

IDE: Godot's built-in editor, used editor-first for both scenes and scripting. Rider (available via existing JetBrains licence) is a known fallback if the built-in editor's limitations become blocking — not set up pre-emptively.

AI-assisted development: Claude Code, used directly against .gd/.tscn files without MCP initially. A Godot MCP server is a known option for later if context-sharing friction becomes a real cost. Neither approach currently lets Claude run the game and self-correct from results.

Testing framework: GdUnit4 — embedded unit testing for GDScript (and C# if needed later), with CI/CD support (JUnit XML, GitHub Actions integration) for when a build pipeline is set up.

Linting & type checking: GDScript supports opt-in static typing natively (type hints on variables/functions), checked by the editor/parser as you write — this is adopted as a coding habit rather than an external tool. gdlint (part of godot-gdscript-toolkit) is used for style/best-practice linting, with CLI support for CI. A newer class of GDScript-specific static analyzers (e.g. code-quality-focused tools that flag missing type hints, high complexity, magic numbers) exists and is worth reassessing later, particularly given potential benefits for reducing AI agent token usage on a larger codebase.

Development machine: macOS (MacBook Air M5) — primary dev loop only, not distribution. No code signing/notarisation required.

Distribution platforms: Windows, macOS, Steam Deck (Linux) — Godot supports native export to all three. Signed/notarised macOS builds are a future concern only if distributing to others.

Display targets: Steam Deck (1280×800, 16:10) is preferred, with standard laptop and monitor configurations (16:9) equally supported — **the game runs unletterboxed across the 16:10–16:9 band, and gets bars outside it.** Within the band, a display sees the maximum its aspect allows; beyond it, the view is clamped and the excess is filled with bars — pillarboxed on anything wider than 16:9, letterboxed on anything narrower than 16:10. Ultrawide is explicitly not a target: a pitch stretched that wide doesn't read well.

Concretely, the visible world is **800 units tall at every supported aspect**, with width floating between 1280 (16:10) and 1422 (16:9). A 16:9 player therefore sees about 11% more pitch width than a Deck player and no extra height. That is a design consequence rather than a fairness one, since [couch co-op](../design/game-vision-and-design-goals.md) puts both players on the same screen.

Configured in Project Settings → Display → Window: base viewport 1280×800, stretch mode `canvas_items`, stretch aspect `expand` — `keep` is the setting that letterboxes unconditionally, `expand` adds no bars and never shows less than the base area. `expand` alone does not clamp, so the 1422-unit width cap and the bars beyond it need implementing rather than configuring. Work at 1280×800 by default and check 16:9 routinely; both are primary.

Physics tick rate: held at 60 ticks/second. It is a feel-critical constant — changing it changes how the ball behaves — so it is set once and treated as fixed rather than tuned, and it is a determinism requirement for headless match simulation — see [Automation Testing](../../ways-of-working/automation-testing.md).

Determinism: simulation logic runs in `_physics_process`, never `_process` — `_process` runs once per rendered frame at a rate that varies with load and display, so anything affecting a match outcome from there is non-reproducible by construction. Elapsed time and randomness are injected — a tick-derived clock and a seeded RNG instance — never read from a global; unseeded `randf()` calls and wall-clock reads are what quietly make headless simulation non-reproducible. Decided once here and honoured as systems are built rather than retrofitted, because this is what makes the same seed plus the same inputs produce the same match twice — see [Automation Testing](../../ways-of-working/automation-testing.md) for what that buys.

Controller testing: 8BitDo Ultimate 2.4G wireless controller, as a stand-in for Steam Deck's native gamepad input.

## Why Godot over Unity

Unity was seriously evaluated as an alternative and rejected. The deciding factor was build friction for the primary target platform — Steam Deck (Linux native) — which is near-zero in Godot versus meaningfully more effort in Unity.

This was a deliberate trade-off, made with the costs understood rather than overlooked: at the time of the decision, Unity offered a more mature automated testing story and first-class C# support, while Godot's testing ecosystem was weaker (community-addon based) and C# support was second-class to GDScript. Both of these costs have since been mitigated in practice — GdUnit4 provides a solid CI-ready testing framework, and GDScript's typed, fast-iteration workflow has offset the appeal of C#'s ecosystem for this project's scope.

Secondary factors reinforcing the decision: Godot's 2D pipeline is native rather than bolted on, its gamepad input (Input Map) is simpler to configure than Unity's Input System, and it uses SDL2 across platforms including Linux — the same layer Steam Deck uses — giving high input parity between the macOS dev loop and the Deck. Godot is also open source, which fits the project's own non-profit/open-source ethos.

The rough heuristic used to decide: start in Godot if the game and the experience of making it matters most; start in Unity if engineering rigour and testability matter most. This project prioritised the former.
# Gamepad Input and Steam Deck Parity

What feels right on the desk should feel identical on the Deck, with no separate input code path. That nearly comes free — Godot normalises every pad onto an Xbox-style layout through SDL's game controller database, the same layer the Deck uses, so the work is *not undermining* it rather than building anything. See [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md).

What each button *does* is the [Player Manual](../docs/manual/player-manual.md)'s controls section; this is the plumbing underneath.

## Controller Setup

**The 8BitDo Ultimate 2.4G wireless stands in for the Deck's own controls** on the desk.

**Project standard: run the 8BitDo in X-input (Xbox) mode.** Bindings, prompts and the Deck comparison all assume Xbox layout, so the controller should speak it from the start rather than being translated after the fact.

- Pair via the USB dongle — macOS recognises it as a generic HID gamepad, no driver needed
- Switch to X-input with a start-up button combination, commonly holding a face button while powering on. **TODO: record the exact combination for the Ultimate 2.4G here** — the dongle may not expose every mode the Bluetooth connection does
- **Avoid Switch mode, sometimes labelled "S".** Its face buttons sit in the opposite physical arrangement to Xbox, so every A/B and X/Y binding comes out transposed — and it presents as a mysterious mapping bug rather than an obvious setting
- **Verify, don't assume.** Project Settings → Input Map, add an event to an action and use the listen-for-input dialog: press the bottom face button, confirm Godot reports the Xbox "A" position. `Input.get_joy_name()` gives the same answer from a scratch script
- Re-check the mode after a re-pair, use with another machine, or a full battery drain — before trusting any mapping bug report
- **Two pads are available**, so couch co-op input can be tested for real once the machine is docked — set both to X-input, and check the mode on each

## Binding Rules

- Define named actions in Project Settings → **Input Map** — `move` and a single contextual `action`, per the single-button pillar — and bind each by Godot's normalised button/axis, never a raw device code. The Input Map labels inputs positionally (bottom action button, left stick X) for exactly this reason
- **Keyboard and gamepad bind to the same action**, so game code never branches on input device
- Read movement with `Input.get_vector()`, not four booleans — analog directional control is not optional in a football game
- **If a trigger is ever bound, bind it as an axis.** `JOY_AXIS_TRIGGER_LEFT` / `RIGHT` as axes keep `Input.get_action_strength()` analog; both the 8BitDo and the Deck are pressure-sensitive, and a digital binding discards that silently. Nothing in the reference scheme needs it — shot power is hold duration, not pressure — so this is insurance, not a plan
- Deadzones are per-action in the Input Map, tuned against real hardware rather than left at the defaults — a feel value, per [On-the-Ball Mechanics](../docs/design/match-engine/on-the-ball-mechanics.md)
- **Ship one prompt set: Xbox glyphs** (A/B/X/Y, LB/RB, LT/RT). Correct on the Deck, on the dev controller, and for most PC players — no controller-family detection
- Godot has no built-in user-facing label (`InputEvent.as_text()` returns developer-facing strings), so the action → glyph lookup is yours to write. Key it off the *action*, not the call site, so remapping stays a change in one place

## Steam Input

The real divergence, and it's engine-independent. Steam Input is Valve's remapping layer, sitting in front of the game — and on a Deck the game normally launches through Steam, so it's in the path whether or not you opted into it.

- It presents a synthetic Xbox-layout pad, which usually helps parity. But `Input.get_joy_name()` may then report something generic rather than the physical hardware, so don't key game logic off the device name — shipping one Xbox prompt set already assumes you won't
- **Test with Steam Input off first**, so you're debugging one layer at a time, then verify with it on as part of the Deck build check — see [Build Pipeline](build-pipeline.md)
- Exercise it early on macOS by adding a local build to Steam as a non-Steam shortcut. A clean run there is a smoke test, not proof, since Steam Input is less mature on macOS than on Linux — but a broken run is a real signal worth catching before the Deck
- No custom profiles for now: they're a distribution-time concern, and Xbox-layout bindings are what the default profile expects, so it should map straight through

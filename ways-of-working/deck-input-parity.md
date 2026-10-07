# Deck Input Parity

The habits that keep desk and Deck input identical. The decision is *Input* in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md); what each button does is the [Player Manual](../docs/manual/player-manual.md)'s controls section.

## The Dev Controller

The 8BitDo Ultimate 2.4G stands in for the Deck's controls.

- **Run it in X-input (Xbox) mode, never Switch mode ("S").** Switch mode transposes A/B and X/Y, and passes for a mapping bug. **TODO: record the start-up combination**
- **Verify before trusting a mapping bug.** In the Input Map's listen-for-input dialog, the bottom face button should report as Xbox "A". Re-check after a re-pair, a different machine or a flat battery — and on both pads when testing co-op

## Binding

- Bind by Godot's normalised button or axis, never a raw device code
- Read movement with `Input.get_vector()`
- Godot has no player-facing input labels, so the glyph lookup is ours. Key it by action, so remapping stays a change in one place

## Steam Input

Valve's remapping layer. On the Deck it's in the path whether opted into or not.

- Test with it off first, then on as part of the Deck build check — see [Build Pipeline](build-pipeline.md)
- Adding a local build to Steam as a non-Steam shortcut exercises it early on the desk — a smoke test, not proof

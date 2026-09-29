# CPU vs CPU Simulation

How matches resolve when nobody's playing them — needed for tournaments and career mode.

**Unresolved, and the main open architectural question in the project.** Two candidate approaches:

- **Displayless run of the real match engine** — same code, no rendering, run fast. Results stay consistent with what the player experiences, and the engine only exists once. Cost: the engine must be deterministic and runnable headless, which constrains how it's built from early on
- **A separate, cheaper simulation** — statistical resolution of duels rather than full physics. Fast enough to fast-forward a season, but it's a second model of football that can drift from the playable one, so the same fixture can plausibly produce different results depending on who's watching

The decision matters early even though the feature is late: the first option only stays available if the match engine is built to support it.

How other matches on a matchday resolve bears on this, and is open — see [Data Architecture — Open Questions](../../../project/data-architecture-open-questions.md). If they only need to *appear* live (goal alerts, a moving table), they can be pre-resolved and their event timelines replayed during the player's match, which costs the first option nothing. If AI in those matches must genuinely react to live scores elsewhere, the first option needs N concurrent instances in lockstep on a shared clock rather than N sequential fast runs.

## Open Questions

- Which of the two above, and if the first, what has to be true of the match engine to keep it viable?
- Does a career season need to fast-forward many matches at once, or is one match at a time enough? This mostly decides how much speed matters
# Licensing and IP

What can go into the repo and the game, and under what licence — the project's own policy, not legal advice. Contributions follow [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

## Licences

Split by what a file does, not its type.

- **Code** — [MIT](../../LICENSE): scripts, and data the engine reads to behave, such as tuning Resources and formation layouts
- **Assets** — [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/): sprites, audio, project-authored fonts, and content the player sees, such as name corpora and kit palettes. Share-alike so that community kit and sprite packs stay open too

## Other Games

Copy the feel, not the files.

**Fine to take:**

- Mechanics, rules and formulas — including numbers read from a disassembly, reimplemented in our own code
- Camera, view and control scheme, single-button input included
- Feel, pace and tuning

**Off-limits:**

- Their code, sprites, tilesets, sound effects, music and fonts — extracted, decompiled or traced — in the repo or any export. Drawing an animation that recreates the feel of one is fine; copying the file isn't. Running on art sideloaded from your own copy is [Local Data](#local-data)
- Pixel-copied menu and HUD layouts
- Their names and logos ("Sensible World of Soccer", "SWOS"), including in this project's name, tagline or marketing

## Real Football

Everything in the game is fictional: no real teams, players, leagues, competitions, crests or kits. This applies now, not at release — the repo is public, and removing anything means rewriting history.

- **Kit colours alone are fine**
- **Don't derive names from real squad lists**
- **Don't let a fictional club combine a real club's name, city and colours**
- **Nothing hosted, bundled or linked** — the project doesn't distribute or endorse real-teams data. Using it locally is [Local Data](#local-data)

## Local Data

What a player brings from their own machine: real-teams data, and the reference game's art sideloaded from a copy they own, standing in until the project's own look replaces it. The project never ships either.

- **A fresh clone works without it.** The generator is the default for teams and committed placeholder art for sprites — local data is a layer on top, not a replacement
- **Out of the repo and every export, by construction.** It lives under `user://`, never `res://`, so neither a commit nor an exported build can pick it up. Settled before an importer exists
- **Sideloaded art is match art only.** The reference's menus aren't worth standing in for, so nothing outside the match loads it
- **Sideloaded art is a stand-in, never a source.** Not traced, not given to an AI generator, and replaced at the same dimensions and anchor
- **Nothing published shows it.** Screenshots, recordings, issues and the README use the project's own art — publishing a capture distributes the art
- **Test fixtures are synthetic.** GdUnit4 suites and CI can't depend on uncommitted data

## Third-Party Intake

Anything from outside needs a known licence, recorded in `CREDITS.md` as it lands — source, author, licence and link. No stated licence, non-commercial or personal-use-only means it doesn't come in.

- **Code and addons** — permissive only (MIT, BSD, Apache 2.0, zlib), so the code stays MIT. No GPL
- **Engine** — Godot is MIT; its export templates carry attribution the shipped build must include
- **Fonts** — SIL OFL is the safe default; "free" often means personal-use-only
- **CC assets** — CC0 and BY are fine, BY with attribution in the form the licence asks for. BY-SA is fine as an asset but never inside code, engine data included. BY-NC never
- **AI-generated assets** — allowed, and licensed BY-SA like any other asset:
  - Only from a generator whose terms let anyone redistribute and adapt the output, commercially included — BY-SA passes those rights on
  - Never prompted with another game's name or assets, or with a real club, player or competition. The output is held to [Other Games](#other-games) and [Real Football](#real-football) like anything drawn
  - Recorded in `CREDITS.md` with the tool, marked as AI-generated

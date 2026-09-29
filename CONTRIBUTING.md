# Contributing

This is a hobby project, currently documentation-first — see [Ways of Working](ways-of-working/README.md) for how the work is done and [Roadmap](project/roadmap.md) for what's being built and in what sequence.

Issues, questions, and discussion are welcome. If you're thinking of a substantial change, raise it before writing it — the project has strong opinions about scope (match-first, fun over realism) recorded in [Game Vision and Design Goals](docs/design/game-vision-and-design-goals.md), and it's better to find a mismatch before the work than after.

## Licensing of Contributions

By contributing, you agree that your contribution is licensed under the project's licences:

- **Code** — [MIT](LICENSE)
- **Assets** — [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — see [Licensing and IP](docs/decisions/licensing-and-ip.md) for exactly what counts as an asset

You also confirm that the material is yours to give — that you wrote it, or that it carries a licence compatible with the above and you've said which. No sign-off ceremony or CLA; opening a PR is taken as agreement to this section.

## What Cannot Be Accepted

The project contains no licensed football content and no material taken from other games. Contributions are declined if they include:

- **Real-world team, player, league, or competition data** — names, squads, crests, badges, kits, or competition marks. This includes seeding a name generator from real squad lists, and generated content that lands on a real club's name, city, and colours together
- **Assets extracted from another game** — sprites, tilesets, palettes, audio, or fonts pulled from a game's files or ROM, and pixel-copied menu or HUD layouts
- **Assets whose licence is unknown, non-commercial, or personal-use-only** — CC BY-NC in particular is incompatible with this project's licensing

This isn't a comment on anyone's intentions; it's that a public repo keeps everything forever, and removing infringing material means rewriting history. [Licensing and IP](docs/decisions/licensing-and-ip.md) has the full reasoning, including where the line falls between taking inspiration from a game and taking its material.

Recreating the *feel* of something from another game is fine and is the point of the project. Recreating its files is not.

## Third-Party Assets

If a contribution brings in an outside asset, add it to `CREDITS.md` with source, author, licence, and link. Provenance recorded as an asset lands takes a minute; reconstructed a year later it's guesswork.

## Changes to Documentation

Documentation is the project's main artefact right now, so doc PRs are real contributions. It lives in three places:

- **`docs/`** — what the game is
- **`ways-of-working/`** — how it gets built. If it's a decision you'd make at the keyboard, it goes here
- **`project/`** — where the work stands: roadmap and live tracking

Keep docs short — bullets over prose. A review pass for duplication and drift is in progress, tracked in [`project/doc-review.md`](project/doc-review.md); `/doc-consistency` runs it.

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

- **Real-world team, player, league, or competition data** — names, squads, crests, badges, kits, or competition marks. This includes names derived from real squad lists, and a fictional club that matches a real club's name, city, and colours together
- **Code or assets taken from another game** — code, sprites, tilesets, palettes, audio, or fonts pulled from a game's files or ROM, decompiled or not, and pixel-copied menu or HUD layouts — or its name or logo used in this project's name or branding
- **Material whose licence is unknown, non-commercial, personal-use-only, or GPL** — CC BY-NC in particular is incompatible with this project's licensing
- **AI-generated assets that don't meet the conditions** in [Third-Party Intake](docs/decisions/licensing-and-ip.md#third-party-intake)

This isn't a comment on anyone's intentions; it's that a public repo keeps everything forever, and removing infringing material means rewriting history. [Licensing and IP](docs/decisions/licensing-and-ip.md) has where the line falls between taking inspiration from a game and taking its material.

Recreating the *feel* of something from another game is fine and is the point of the project. Recreating its files is not.

## Third-Party Material

If a contribution brings in anything from outside, add it to `CREDITS.md` as [Third-Party Intake](docs/decisions/licensing-and-ip.md#third-party-intake) describes.

## Changes to Documentation

Documentation is the project's main artefact right now, so doc PRs are real contributions. It lives in three places:

- **`docs/`** — what the game is
- **`ways-of-working/`** — how it gets built. If it's a decision you'd make at the keyboard, it goes here
- **`project/`** — where the work stands: roadmap and live tracking

Keep docs short — bullets over prose. `/doc-review` reviews one doc at a time and `/doc-consistency` checks the whole set for duplication and drift.

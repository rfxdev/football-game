# Licensing and IP

Not legal advice — the project's own policy, so decisions about content, assets and contributions have something to check against.

## 1. Licensing

- **Code** — [MIT](../../LICENSE)
- **Assets** — [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Covers sprites, audio, project-authored fonts, and content data such as name corpora and kit palette definitions

Split stated in the [README](../../README.md). BY-SA over a more permissive licence so that community derivatives — kit and sprite packs — stay open the way the project itself is.

## 2. Inspiration, Not Appropriation

Taking inspiration from published games (SWOS and similar) is the point of the project. Copying their files is not.

**Fine to take:** mechanics, rules, and systems; camera and view; control scheme, including single-button input; feel, pace, and tuning; the general idea of a top-down arcade football game.

**Off-limits:** their sprites, tilesets, sound effects, music, and fonts (extracted, decompiled, or traced — recreating the *feel* of an animation by drawing one is fine, copying the file isn't); pixel-copied menu and HUD layouts; and their names and logos ("Sensible World of Soccer", "SWOS", etc.), including in this project's own name, tagline, or marketing.

## 3. No Licensed Football Content

No real teams, players, leagues, competitions, crests, or kits. The repo is public — already distribution — so this applies now, not at some future release.

- **Protected:** real player names and name-plus-club combinations (image/personality rights), club names/crests/badges and competition names/marks (trademarks)
- **Not protected:** kit colours alone

Generation is the answer: procedurally generated clubs, players, kits, and competition names are original by construction; hand-authored fictional teams work too. Two traps to avoid — don't seed a name generator from real squad lists, and don't let a generated club land on a real club's name, city, and colours together.

The project stays capable of *loading* an external real-teams data pack someone else builds, but doesn't host, bundle, link to, or endorse one.

## 4. Third-Party Asset Intake

Anything brought in from outside needs a known licence, recorded in a single `CREDITS.md` as it lands:

- **Engine and tooling** — Godot is MIT; its export templates carry attribution requirements for the shipped binary
- **Fonts** — SIL OFL is the safe default; "free" often means personal-use-only
- **CC-licensed assets** — BY needs attribution in the form the licence specifies; BY-SA is share-alike, which can conflict with the project's own asset licence; BY-NC is incompatible with this project full stop
- **AI-generated assets** — copyright status is unsettled in several jurisdictions and some generators restrict redistribution; decide deliberately if any are used

## 5. Contributions

Governed by [`CONTRIBUTING.md`](../../CONTRIBUTING.md) — written up front rather than deferred to the first outside PR, so there's no case to argue on the spot.
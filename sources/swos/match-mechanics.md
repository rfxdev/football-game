# SWOS Match Mechanics

Attribute definitions and their big-picture gameplay effect are covered in [Player Ratings](player-ratings.md). This document covers the detail of each mechanic and how the relevant attributes shape it.

Citations are to two disassemblies: `swos-port/swos/swos.asm` (DOS, whose names make the logic readable) and `original-amiga-swos/original-amiga-swos.asm` (Amiga, the [reference version](../../docs/decisions/architecture-and-stack.md)). Where both are cited, the two match unless the text says otherwise.

## On-the-Ball Mechanics

### Movement

Speed sets a player's base movement value, looked up from a table by their Speed skill (`UpdatePlayerSpeed`, `swos-port/swos/swos.asm:105206-105241`, `original-amiga-swos.asm:35391-35413`; `kPlayerSpeedsGameInProgress`: 928 at Speed 0 up to 1250 at Speed 7 — roughly a 35% swing top to bottom). Three flat, skill-independent modifiers apply on top of that base value, all in the same function:

- **Carrying the ball** cuts a player's speed to 87.5% of their base value, applied unconditionally to whoever currently controls the ball (`swos.asm:105285-105301`, `original-amiga-swos.asm:35437-35446`).
- **After a goal is scored**, every player's speed drops to 62.5% until play resets (`runSlower` flag, `swos.asm:105242-105255`, `original-amiga-swos.asm:35414-35421`).
- **An in-match injury** subtracts a fixed amount scaled to its severity (`kInjuriesSpeedHandicap`: 0 at no injury down to -288 at the worst degree; `swos.asm:105257-105283`, `original-amiga-swos.asm:35422-35436`) — but only for a human- or player-coach-controlled team; the check is skipped entirely for a fully CPU-controlled side.

### Ball Control

Ball Control governs how well a carrier keeps the ball at their feet while running and turning — the manual: "as you run faster and attempt to turn with the ball you'll find it harder to keep control." The disassembled engine (`CalculateIfPlayerWinsBall`, `swos-port/swos/swos.asm:108107-108351`, `original-amiga-swos.asm:35144-35277`) pins down the specifics behind that line:

- **Running straight:** two ticks on, two off, the ball's speed is set to the carrier's own speed plus an offset drawn from a table indexed by their Ball Control (`kBallSpeedDeltaWhenControlled`, 130 at Ball Control 0 down to 32 at 7; `swos.asm:108274-108276`, `original-amiga-swos.asm:35234-35236`). Low Ball Control widens that offset, so the ball runs a little further ahead of the player's feet in those ticks.
- **Turning:** holding a turn increments a timer that's compared each frame against a Ball-Control-scaled threshold (4 frames at Ball Control 0 up to 21 at 7); overrunning it strips the ball to the opponent (`swos.asm:108316-108346`, `original-amiga-swos.asm:35263-35271`). Low Ball Control shortens that threshold, so this is the mechanic where poor control costs a dribbler the ball.
- **Standing/running challenge:** the same function also resolves a defender contesting a carrier just by running into them (or closing on a loose ball), no action button required — a passive duel. Both players run the identical formula — their own **(Tackling + Ball Control) ÷ 2** — and the *difference* between the two averages is looked up in a probability table to decide who wins the ball (`swos.asm:108141-108176`, `original-amiga-swos.asm:35158-35180`), so a player strong in one of the pair and weak in the other performs the same as a balanced player with an equal average.

### Sliding

Triggered by tapping the action button while the ball is beneath chest height (the header fires instead above chest height — see Heading below), regardless of whether an opponent is involved — a deliberate action, committed to a fixed direction (the manual: "a sliding tackle in the direction he is running"). On a successful slide, holding the stick diagonally left or right of that direction deflects the ball 45° that way instead of sending it straight on; the same slide and deflection option fires on a genuinely loose ball too, contesting a bouncing 50/50 in midfield or sliding in to poke home a loose ball or rebound in the box.

**The lunge itself is a fixed, decelerating burst, independent of the player's own Speed rating.** `PlayerBeginTackling` (`swos-port/swos/swos.asm:106329-106403`, `original-amiga-swos.asm:39559-39592`) sets `Sprite.speed` to a hardcoded constant — `kPlayerTacklingSpeed` = 1792, or 3.5 pixels per tick in the engine's own speed units — the same for every player, and faster than even a Speed-7 player's 2.44-pixel-per-tick running top speed (`kPlayerSpeedsGameInProgress[7]` = 1250). From the next frame, the per-frame tackling handler (`@@player_tackling`, `swos.asm:115733-115787`, `original-amiga-swos.asm:44014-44048`) bleeds that speed off by a flat `kPlayerGroundConstant` (96) every frame until it hits zero: 19 frames, about 0.38 seconds at the Amiga's 50 Hz (see Engine Performance), covering roughly 34 pixels total. Only once speed reaches zero does `SetPlayerDowntimeAfterTackle` run and the lying-down recovery below begin.

**Tap or hold sets the tackle's strength**, in the same handler. A human who lets go of the button within the slide's first two frames makes a *weak* tackle; holding it longer makes a *strong* one. The CPU never lets go, so its tackles are always strong. Strength decides the ball's speed off the connect, and the recovery time below. Either way the tackler drops to half speed; the ball leaves at 0.75× the tackler's speed at contact from a weak tackle (`PlayerTackledTheBallWeak`, `swos.asm:109545-109562`, `original-amiga-swos.asm:35334-35341`), 1.25× from a human's strong one and 1× from the CPU's (`PlayerTackledTheBallStrong`, `swos.asm:106496-106534`, `original-amiga-swos.asm:39640-39658`). The slide decelerates, so the earlier in it the ball is reached, the harder it goes.

**Against a carrier**, each frame of the slide checks two things, both against the opponent's controlled player — normally the carrier (`swos.asm:115847-115949`, `original-amiga-swos.asm:44091-44149`):

- **Reaching the ball** — the tackler's sprite within 8 pixels of it (`Sprite.ballDistance <= 64`, a squared distance recomputed each frame for every player, `swos.asm:100896-100925`, `original-amiga-swos.asm:36993-37002`) — takes it, weak or strong. Reaching the ball is never itself a foul, from any angle. At that moment the tackle is marked **clean** for the rest of the slide if the opponent is neither on the ball (within 3 pixels) nor touching the tackler (within about 5.7 pixels); otherwise it's marked as having **touched the ball** (`tackleState`, `swos.asm:106536-106578`, `:109564-109602`).
- **Running into the opponent** — within about 5.7 pixels, while the slide still moves at 1 pixel per tick or more and the opponent is within about 28 pixels of the ball — is checked for a foul by the tackle's state (`PlayerTacklingTestFoul`, `swos.asm:106986-107268`, `original-amiga-swos.asm:39106-39281`):
  - **Ball not yet touched:** always a foul, from any angle.
  - **Touched the ball:** a foul only if the tackler is moving the same way the opponent faces, within ±1 on the direction scale — from behind. Otherwise clean.
  - **Clean:** never a foul.
  - A goalkeeper is never fouled this way; the tackler just drops to a quarter of their speed.

So a slide that misses the ball and takes the player is a foul from any angle, and one that wins the ball but carries on into the player is a foul only from behind. From behind, the ball sits beyond the carrier, so a tackler reaching it is likely to be on top of the carrier already — the clean mark is rarely earned from there.

**After any tackle attempt**, the tackling player is left lying on the ground (`SetPlayerDowntimeAfterTackle`, `swos.asm:105173-105197`, `original-amiga-swos.asm:35371-35385`). After a strong tackle, Tackling skill sets how long, on a clean linear scale (`kStrongTackleDownTime`: 30 frames at Tackling 0 down to 9 frames at Tackling 7 — 3 frames faster per skill point); after a weak one it's a flat 3 frames whatever the skill (`kWeakTackleDownTime`; both tables at `original-amiga-swos.asm:34742-34773`). The CPU's tackles are always strong, so its recovery always scales with Tackling.

#### Fouls, Cards & Injuries

A foul always results in a stoppage — a penalty or free kick either way, decided independently of any card outcome (`TestFoulForPenaltyAndFreeKick`, called on every path out of `PlayerTacklingTestFoul`, `swos.asm:107243-107267`, `original-amiga-swos.asm:39256-39280`). Whether it also draws a card is gated first by a timer-jittered check against `playerCardChance`, a configurable per-match setting — missing that gate means no card at all.

**Where the foul happens changes the odds.** Inside the penalty box (`swos.asm:107115-107132`, `original-amiga-swos.asm:39176-39193`), the standard roll applies: roughly 12.5% straight red, 87.5% yellow (`swos.asm:107229-107245`, `original-amiga-swos.asm:39244-39256`). Outside the box, the engine first checks for cover — comparing the tackler's own closest teammate's distance to the fouled player against the fouled player's own distance to goal (`swos.asm:107134-107225`, `original-amiga-swos.asm:39197-39241`). If no teammate was closer than the goal itself — nobody covering, a last-man situation — the odds invert to roughly 87.5% straight red / 12.5% yellow instead (`swos.asm:107250-107262`, `original-amiga-swos.asm:39263-39275`); otherwise it's the same standard roll.

**A second yellow card in the same match is an automatic sending-off**, explicitly modeled (`TryBookingThePlayer`, `swos.asm:107411-107457`, `original-amiga-swos.asm:38427-38452`): a player's per-match card count is tracked directly, and hitting 2 produces a distinct `CARD_SECOND_YELLOW` outcome — reversing the earlier booking tally, counting it as a sending-off instead, and drawing down the team's shared injury/dismissal budget (see below).

**Injuries are rolled independently of the foul/card outcome**, on every tackle collision regardless of whether it's later ruled clean or a foul (`PlayerTackled`, `swos.asm:107856-108032`, `original-amiga-swos.asm:36096-36204`, called before any card logic runs). Each team draws from a shared budget (`team1NumAllowedInjuries`/`team2NumAllowedInjuries`, also drawn down by a second-yellow send-off above) — once it hits zero, no further injuries or send-offs can occur that match. While the budget allows it:

- The chance of any injury is scaled by the match-length setting (`kTackleInjuryProbability`: 18.75%, 10.9%, 7.8%, 5.5% per tackle across four settings — decreasing as matches get longer, keeping total expected injuries per match roughly stable) and **roughly doubles for a player already carrying a knock** (`kTackleInjuryProbabilityAlreadyInjured`: 37.5%, 22.3%, 16.0%, 10.9%). The check matches the mildest injury degree only; a player carrying anything worse rolls on the normal tables (`swos.asm:107899-107906`, `original-amiga-swos.asm:36124-36131`).
- Severity, when an injury occurs, is a weighted roll across 7 levels (`kInjuryLevels`: weights 42/7/5/4/3/2/1 out of 64 — the mildest "knock" alone accounts for ~66%). **A player already carrying a knock rolls hard toward the severe end** (`kInjuryLevelAlreadyInjured`: weights 14/15/12/9/7/5/2 out of 64 — the mildest outcome drops to ~22%) — quantifying what the Jon Hare Q&A only implied (see [Career Mode Mechanics](career-mode-mechanics.md)).

### Heading

Heading shares the slide's action button: the ball's height at the moment of the press decides which action fires — below chest height triggers a slide (see Sliding above), above it triggers a header. Which of the two header types below you get is then decided by the stick position at that same moment.

#### Dive (stick pushed in a direction)

The player throws themselves forward in that direction to reach the ball. Holding a direction through the dive, up to the moment of contact, aims the header:

- **Deflection:** 45° left or right of the direction faced.
- **Height:** toward the direction faced keeps it low, centered lobs it, pulled back sends it high.
- The two combine — e.g. back-and-right gives a high header angled 45° right — matching shooting's height mapping (below), but aimed during the dive rather than adjusted after contact.

#### Jump (stick centered)

The player jumps straight up. Diverting the stick afterward, while hanging in the air, redirects the header as a **flick-on** — freely toward wherever the stick is now pointing, not constrained to the dive's ±45° window. The manual describes this purely as a directional flick, with no equivalent height/loop control.

**Why these are split rather than one shared system:** the dive's 45°-deflection/height rules are explicitly anchored to "the direction you are facing," which only applies once a dive has established a facing/movement direction to deflect from. The jump-into-flick-on case starts from a neutral stick and is described only as pointing the flick "in the direction in which you are pointing" — no height language attached at all.

### Passing

Passing skill widens both the maximum pass length and the passing cone — how far off-axis a teammate can be and still register as a valid target.

**Aftertouch also shapes the pass**, relative to the pass's own direction rather than absolute up/down:

- Continuing to hold the stick in the pass direction plays a short, early pass — the receiver moves back toward the passer to meet it.
- Centering the stick, or pulling it to the opposite direction, plays the default grounded pass — the receiver holds position and waits for the ball to reach their feet.
- Angling the stick diagonally *with* the pass direction plays the ball to the receiver's side; they shift sideways to intercept it.
- Angling the stick diagonally *against* the pass direction plays the ball beyond the receiver — a through-ball they have to run onto.

### Shooting & Finishing

Finishing's shot multiplier only triggers inside the box — it has no effect on headers or shots from outside the area — and the result feeds into the keeper's save-chance calculation.

**Aftertouch is relative to the kick's own direction, not an absolute up/down on the stick:**

- Continuing to hold the stick in the same direction as the kick keeps the ball low and driven.
- Pulling the stick to the opposite direction sends the ball high into the air.
- Centering the stick produces a looping lob.
- Angling the stick left or right of the kick direction curls the ball that way — a continuous swerve, unlike heading's discrete 45° deflection.
- **Reaction speed scales the effect:** the sooner the stick moves after the kick, the more dramatic the resulting bend, lob, or drive — aftertouch fades the longer you wait to apply it.

Throw-ins, corners, goal-kicks, and penalties all use this identical kick control scheme — there's no separate input method for dead-ball situations.

## Engine & AI Behaviour

### Pitch and View

**The world is 672 × 880 pixels, of which the camera can show 672 × 848; the Amiga screen is 336 × 272 and the DOS screen 320 × 200.** Both versions use the same world coordinates.

**The pitch:**

- **The tile map is 42 × 55 tiles of 16 pixels**, 672 × 880 (`kVirtualPitchPatternsX`/`Y`, `swos-port/tools/swpe/src/h/pitch.h:13-14`). That is the bound the pass code checks against — 672 on x, 880 on y (`swos.asm:108484`, `original-amiga-swos.asm:34931-34936`)
- **The camera never shows the top or bottom tile row.** Its top edge stops at y 16 and its bottom edge at 864 in both versions (clamps below), so the viewable area is 848 tall. That area is the pitch editor's `PITCH_W`/`PITCH_H` (`pitch.h:7-8`) and the "42 × 53 patterns" of the port's pitch notes (`swos-port/docs/SWOS/pitch.txt`). **So 880 is the whole map and 848 is the part ever on screen**
- **The playing area is 510 × 641.** Touchlines are at x 81 and 590, goal lines at y 129 and 769, and the centre spot at (336, 449). Penalty areas run from x 193 to 478, and from the goal line to y 216 at the top and 682 at the bottom (`swos.asm:107112-107134`, `original-amiga-swos.asm:39174-39194`; touch and goal lines also at `original-amiga-swos.asm:36032-36047`). The goal lines are these constants and are not tied to either edge of the map, so neither 848 nor 880 moves them

**The Amiga screen is 336 × 272, low-res, not interlaced, with a little overscan.** It is set by the game's copper list (`original-amiga-swos.asm:6620-6936`), which is loaded into COP1LC at `:6484`, the only write to that register:

- **BPLCON0 = $4000** (`:6688`): four bitplanes (16 colours), low-res, no interlace. Nothing rewrites it
- **DIWSTRT = $2471 and DIWSTOP = $34C1** (`:6724-6728`): a display window from line $24 to $134 and from column $71 to $1C1, 272 lines by 336 pixels. The standard PAL low-res window is 320 × 256. This one starts 16 pixels further left and adds 8 lines at the top and 8 at the bottom
- **DDFSTRT = $28 and DDFSTOP = $D0** (`:6716-6720`). The scroll routine switches DDFSTRT between $30 and $28, and adjusts the modulos to match (`:6528-6540`). The extra word fetched at $28 is for fine horizontal scrolling. The source is a 352-pixel-wide buffer (`:6594`) that wraps vertically every 272 lines (`:6599-6615`)
- **The camera code agrees.** It centres on the ball by subtracting 168 and 136 (`:21399-21400`), half of 336 × 272. DOS subtracts 160 and 100 (`swos.asm:102589-102590`)

The DOS screen is mode 13h, set at `swos.asm:7289`. The 64000-byte screen dump at `swos.asm:14575` and `WIDTH`/`HEIGHT` in `tools/swospp/main/swos.h:13-14` confirm it.

**Both cameras stop at the same pitch edges.** In open play the view spans x 63 to 609: the limit is set at `original-amiga-swos.asm:21323-21326`, and the right-hand clamp is 336 minus the limit on the Amiga (`:21408`) against 352 minus it on DOS (`swos.asm:102603`). The limit is 37 at throw-ins and corners, per the port's `docs/SWOS/camera.txt`. Vertically the view runs from y 16 to 864: the top edge is clamped to 16–592 on the Amiga (`original-amiga-swos.asm:21429-21434`) and to 16–664 on DOS (`swos.asm:102628-102633`). The Amiga's larger window therefore scrolls less. It does not reach any further.

| | DOS | Amiga |
| --- | --- | --- |
| Window | 320 × 200 | 336 × 272 |
| Share of the viewable 672 × 848 | 47.6% × 23.6%, about 11% | 50.0% × 32.1%, about 16% |
| Share of the 510 × 641 playing area | 63% × 31% | 66% × 42% |
| Camera travel, x / y (open play) | 226 / 648 | 210 / 576 |

The Amiga shows about 5% more width than DOS, 36% more length and 43% more area.

**Pixel shape:**

- **DOS pixels are 1 wide by 1.2 tall.** That is 320 × 200 stretched over a 4:3 monitor
- **Amiga pixels are about 1.04 wide by 1 tall.** This comes from the PAL low-res dot clock measured against the PAL line. The 336 × 272 window didn't fill the tube: it took about 91% of the active line and 94% of the visible lines. Stretching it to fill 4:3, which gives 1.08, overstates the width. The window as seen is about 1.28:1
- **The art is squashed along the pitch, in pixels.** A metre up the pitch gets about three-quarters of the pixels that a metre across gets:
  - The penalty area is 286 × 88 pixels against the Laws' 40.3 × 16.5 m, a ratio of 0.75
  - The centre circle is about 127 × 99 pixels, a ratio of 0.78. This is measured from swos-port's redrawn pitch tiles, which follow the original 16-pixel grid at 12× (`swos-port/assets/pitches/pitch1`), so it is accurate to about a pixel
  - The playing area gives 0.81 against a 68 × 105 m pitch. This one is soft, because the Laws allow a range of pitch sizes
- **The ball is 4 × 4, round in pixels.** Its sprites are `kBallSprite1`–`4`, `swos-port/src/sprites/sprites.h:252-255`
- **This points to art drawn for near-square pixels, with the ground foreshortened.** On the Amiga, the markings show at about three-quarters depth. That is how the ground looks from a camera tilted away from overhead, the angle the players are drawn from, and a ball stays round from any angle. On DOS, the tall pixels stretch the markings to within a few percent of a true overhead view, and stretch the ball to 1.2 tall. If the squash were compensating for DOS pixels, the ball would have been drawn 4 × 3. At four pixels this is thin evidence, but only the Amiga reading fits both the ball and the markings
- **Movement is the same number of pixels on x and y.** Turning a direction into a velocity multiplies a single speed by a sine and a cosine from one table (`CalculateDeltaXAndY`, `swos.asm:69501-69663`, `original-amiga-swos.asm:20661-20760`). Every reach and tackle distance is a squared pixel distance, x² + y² (`swos.asm:100896-100925`, `original-amiga-swos.asm:36993-37002`). As a result:
  - **Measured against the markings,** a player runs up the pitch about 1.3× faster than across it, and reach and tackle circles are that much longer along the pitch. This is part of the world, so it holds on any display
  - **On the screen,** up-field movement looked about 4% slower than sideways movement on the Amiga, and 20% faster on DOS. Square pixels show the two as equal, which is within 4% of the Amiga

Consequences, since they are easy to get wrong from screenshots:

- **The view scrolls on both axes.** Neither version shows anything like the whole pitch, and the window covers far more of the pitch's width than of its length
- **The pitch is portrait**, taller than it is wide, matching the vertical attacking orientation the manual describes.
- **Speeds elsewhere in this document are in these pixels.** A Speed-7 player's 2.44 px/tick crosses the 672-pixel width in about 275 ticks, about 5.5 seconds at the Amiga's 50 Hz (see Engine Performance).

### Kits

**DOS only.** The Amiga disassembly has no kit code — it covers the match engine — so this section cites `swos.asm` and swos-port's notes alone.

**A team has two kits, primary and secondary, each a shirt type and four colours from a palette of ten** (team file layout, `swos-port/docs/SWOS/teams.txt:66-91`):

- **The palette:** grey, white, black, orange, red, blue, brown, light blue, green, yellow
- **A kit:** shirt type, shirt colour, second shirt colour, shorts colour, socks colour
- **Four shirt types:** plain, contrasting sleeves, vertical stripes, horizontal stripes (`ShirtTypes`, `swos-port/src/swos/swos.h:445-451`). A plain shirt ignores its second colour

**One set of art per shirt type, recoloured at match start** (`swos-port/docs/SWOS/sprites.txt:45-50`, `:218-243`, `:421-470`):

- **Sprites are drawn in placeholder palette entries** — shirt, second shirt colour, shorts, socks, and shades of skin and hair — swapped for the team's colours when the match starts (`ConvertTeamKitColors`, `swos.asm:36570-36609`)
- **Plain shirts reuse the vertical-stripe art** with both shirt colours set the same
- **Skin and hair aren't recoloured per player.** Each team's outfield sprites are copied three times, one per complexion, and each player draws from his copy
- **Keepers have their own sprites**, a main and a reserve per team, recoloured with the same per-team table as the outfield sprites (`ConvertColorsAndTextSprites`, `swos.asm:97032-97131`). Their shorts and socks are drawn in the kit's shorts and socks entries, so they follow whichever kit the team is wearing
- **Every keeper wears the same shirt.** The keeper art draws its shirt in palette entry 7, not the kit's shirt entries — swos-port's sprite split finds no kit-shirt pixels in it (`swos-port/assets/convertGameSprites.py:131-135`) — and both teams' tables convert entry 7 to entry 0 (`team1PlayersColorTable`, `swos.asm:245380`). The pre-match menu does the same: the keeper keeps his drawn shirt and takes only the team's shorts and socks (`StadiumPlayerSpritesBeforeDraw`, `:85685-85758`). What entry 0 looks like in a match isn't established from the code; swos-port draws it near-black (`swos-port/src/game/color.cpp:3-7`)

**A clash is a score, not a lookup.** `GetTeamKitsSimilarityFactor` (`swos.asm:36855-37265`) compares two kits' shirt types, shirt colours and shorts — never socks — against two tables of colour pairs that read alike: one for shirt against shirt, one for second colour against shorts (`teams.txt:105-129`). Each pair that reads alike adds points, weighted by which parts are compared; 11 or more is a clash.

**At match start, the first combination that doesn't clash is worn** (`SetInGameTeamsPrimaryColors`, `swos.asm:36193-36274`; `MeasureTeamKitsSimilarity`, `:36692-36838`; `SetInGameTeamColors`, `:36473-36557`):

1. Both primary kits
2. Team 2 in its secondary
3. Team 1 in its secondary, team 2 in its primary
4. Both secondaries
5. Team 2 in a single-colour kit — shirt, shorts and socks all one colour — trying its own colours in turn: primary second colour, primary shirt, primary shorts, then the same three from its secondary. Checked against team 1's primary (`IsSingleColorKitSimilar`, `:36285-36326`)
6. Team 2 in a single colour from a fixed order: red, blue, white, light blue, yellow, grey, orange, brown, green, black (`teamKitTieBreakColors`, `:217984`; `ResolveTeamKitColorConflict`, `:36372-36461`)
7. Nothing works: team 1 all red, team 2 all blue, both in white shorts

Team 1 changes kit only at step 3; from step 5 on, it always wears its primary. The comments in `SetInGameTeamsPrimaryColors` label steps 2 and 3 the other way round, but the flags `SetInGameTeamColors` reads put team 2 first.

### Engine Performance

- **One logic tick per displayed frame, locked to the display's refresh.** No fixed timestep, catch-up or frame skipping: each pass of the match loop updates everything once, then waits for the next refresh to show the frame. A frame that overruns misses a refresh and the game slows rather than catching up. So the tick rate is the refresh rate:
  - **DOS: 70 ticks per second.** `Flip` waits on the VGA vertical-retrace bit (port 0x3DA) before copying the frame to video memory (`swos-port/swos/swos.asm:135838-135861`), once per pass of the match loop (`GameLoop`, `swos.asm:7612-7751`); mode 13h refreshes at about 70 Hz. The PIT runs alongside at divisor 17045 (`swos.asm:11678-11679`), 1193181 ÷ 17045 ≈ 70 Hz, re-armed on every `Flip` (`swos.asm:135835-135837`, `ProgramPIT` at `swos.asm:12370-12384`). Its callback `TimerProc` (`swos.asm:12194-12214`, registered through the audio library at `swos.asm:141274-141344`) only counts ticks; the loop passes the count elapsed since the last frame to the match clock and on-screen timers (`ReadTimerDelta`, `swos.asm:18902-18917`), never to movement.
  - **Amiga: 50 ticks per second (PAL).** The vertical-blank interrupt raises a software interrupt (`original-amiga-swos/original-amiga-swos.asm:9335-9353`), whose handler counts ticks and swaps the screen once the match loop has flagged a frame finished, at least one vertical blank since the last swap — a minimum only ever set to 1 (`original-amiga-swos.asm:6174-6221`). The match loop updates once, then spins until that swap (`maingame`, `original-amiga-swos.asm:31092-31153`). There's no PAL/NTSC check: the rate is the machine's vertical blank, 50 Hz on the PAL machines it shipped for.
- **Same per-tick numbers, so DOS plays about 40% faster.** Everything this doc cites in per-tick units is identical on the Amiga, not rescaled for 70 Hz: the player speed table (`original-amiga-swos.asm:34726-34733`), tackling speed 1792 (`:30706`), ground constant 96 (`:30584`) and the tackling handler that applies it (`:44014`), the tackle downtime tables (`:34742-34773`) and the injury speed handicap (`:35536`). A Speed-7 player covers about 171 px/s on DOS and 122 px/s on the Amiga. A few fixed timers were stretched by only 10% — those set when a tackle or header starts are 55 frames on DOS (`swos.asm:106344`, `:109009`) against 50 on the Amiga (`original-amiga-swos.asm:39567`, `:39693`); the port's Amiga mode lists more such retunings, ball friction and keeper dives among them (`swos-port/src/game/amigaMode.cpp:23-62`). Frame counts in this doc are ticks: divide by 70 for DOS seconds, 50 for Amiga.
- **50 Hz is the intended pace; DOS's 70 is a porting bug.** The code shows it: DOS kept the Amiga's per-tick numbers, and its only rate adjustment found is the 10% timer stretch above, about a quarter of what 70 against 50 needs.
- **High frame rate, frantic pace.** The high frame rate is credited for the game's snappy feel; online latency is what breaks it. There are zero long animations to wait out, and players can pivot instantly — the game leans on raw reflexes, prediction, and quick execution rather than animation-driven timing.
- **One hitbox per player**, not per limb.

### Controls

- **One button, fully contextual.** The entire on-pitch engine runs off just a directional stick and a single action button — context and timing determine the outcome, not a complex layout.
- **Tap** the button for a short pass or a slide; **hold** it to power up a shot or long lob.
- **Aftertouch:** for kicks and passes, pushing the stick in a direction immediately after the button applies a violent swerve, curl, or height change to a ball that's already in flight, relative to the direction of the kick itself rather than absolute up/down. Headers use the same relative-direction mapping but aim it earlier — during the jump/dive, before the head meets the ball, rather than after. See Heading, Passing, and Shooting & Finishing above for how each action interprets it.
- **Next-player selection follows joystick direction** at the moment of the switch; leaving the stick neutral doesn't speed selection up and effectively continues using the last direction pushed.
- **No dedicated switch button.** With the single action button already committed to sliding/heading/shooting, control while out of possession isn't manually assigned — the engine automatically hands control to whichever of your players is closest to the ball, reassigning it continuously as the ball (and players) move.

### AI Behavior

- **At least one CPU player always actively chases the ball**, running onto it whenever possible, independent of tactical shape.

### Manager's Bench

Tapping the same stick direction three times in quick succession — at any moment the ball is dead (out of play, or held by a keeper) — brings up both teams' benches without leaving the match. From there you can: swap two outfield players' positions without using a substitution, make an actual substitution (only usable while the ball is out of play), switch to a different pre-defined formation on the fly, or hold the button on a player's name to give them a permanent on-pitch highlight (flashing diamond) for the rest of the match. Push the stick to either side to dismiss the bench and resume play.

Assistant Coach fit feedback (see [Tactics and Team Selection](tactics-and-team-selection.md)) doesn't apply here — bench changes get no tick/cross evaluation at all, unlike the same swaps made pre-match.

## Open Questions

- **Does the closest-player auto-switch (see Controls above) have any hysteresis or debouncing?** The manual only says control "usually" goes to the player closest to the ball, and the Jon Hare Q&A's only note on player selection covers the in-possession next-teammate case, not off-the-ball switching. Unclear whether the original engine does anything to stop control flapping between two similarly-distant defenders, or whether that never came up because of some other factor (hitbox/positioning spacing, frame-rate smoothing, etc.).

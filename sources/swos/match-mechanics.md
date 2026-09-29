# SWOS Match Mechanics

Attribute definitions and their big-picture gameplay effect are covered in [Player Ratings](player-ratings.md). This document covers the detail of each mechanic and how the relevant attributes shape it.

## On-the-Ball Mechanics

### Movement

Speed sets a player's base movement value, looked up from a table by their Speed skill (`UpdatePlayerSpeed`, `swos-port/swos/swos.asm:105193-105228`, `kPlayerSpeedsGameInProgress`: 928 at Speed 0 up to 1250 at Speed 7 — roughly a 35% swing top to bottom). Three flat, skill-independent modifiers apply on top of that base value, all in the same function:

- **Carrying the ball** cuts a player's speed to 87.5% of their base value, applied unconditionally to whoever currently controls the ball (`swos.asm:105281-105288`).
- **After a goal is scored**, every player's speed drops to 62.5% until play resets (`runSlower` flag, `swos.asm:105229-105242`).
- **An in-match injury** subtracts a fixed amount scaled to its severity (`kInjuriesSpeedHandicap`: 0 at no injury down to -288 at the worst degree) — but only for a human- or player-coach-controlled team; the check is skipped entirely for a fully CPU-controlled side.

### Ball Control

Ball Control governs how well a carrier keeps the ball at their feet while running and turning — the manual: "as you run faster and attempt to turn with the ball you'll find it harder to keep control." The disassembled engine (`CalculateIfPlayerWinsBall`, `swos-port/swos/swos.asm:108094`) pins down the specifics behind that line:

- **Running straight:** every other frame, the ball's speed is set to the carrier's own speed plus an offset drawn from a table indexed by their Ball Control (`kBallSpeedDeltaWhenControlled`). Low Ball Control widens that offset, so the ball runs a little further ahead of the player's feet on alternating frames.
- **Turning:** holding a turn increments a timer that's compared each frame against a Ball-Control-scaled threshold; overrunning it strips the ball to the opponent. Low Ball Control shortens that threshold, so this is the mechanic where poor control costs a dribbler the ball.
- **Standing/running challenge:** the same function also resolves a defender contesting a carrier just by running into them (or closing on a loose ball), no action button required — a passive duel. Both players run the identical formula — their own **(Tackling + Ball Control) ÷ 2** — and the *difference* between the two averages is looked up in a probability table to decide who wins the ball, so a player strong in one of the pair and weak in the other performs the same as a balanced player with an equal average.

### Sliding

Triggered by tapping the action button while the ball is beneath chest height (the header fires instead above chest height — see Heading below), regardless of whether an opponent is involved — a deliberate action, committed to a fixed direction (the manual: "a sliding tackle in the direction he is running"). On a successful slide, holding the stick diagonally left or right of that direction deflects the ball 45° that way instead of sending it straight on; the same slide and deflection option fires on a genuinely loose ball too, contesting a bouncing 50/50 in midfield or sliding in to poke home a loose ball or rebound in the box.

**The lunge itself is a fixed, decelerating burst, independent of the player's own Speed rating.** `PlayerBeginTackling` (`swos-port/swos/swos.asm:106316-106390`) sets `Sprite.speed` to a hardcoded constant — `kPlayerTacklingSpeed` = 1792, or 3.5 pixels per tick in the engine's own speed units — the same for every player, and faster than even a Speed-7 player's 2.44-pixel-per-tick running top speed (`kPlayerSpeedsGameInProgress[7]` = 1250). From the next frame, the per-frame tackling handler (`@@player_tackling`, `swos.asm:115715-115771`) bleeds that speed off by a flat `kPlayerGroundConstant` (96) every frame until it hits zero: 19 frames, about 0.32 seconds at 60fps, covering roughly 34 pixels total. Only once speed reaches zero does `SetPlayerDowntimeAfterTackle` run and the lying-down recovery below begin.

**Against a carrier**, every frame of that decelerating window re-checks whether the tackler's sprite has closed to within 8 pixels of the ball (`Sprite.ballDistance <= 64`, a squared distance recomputed each frame for every player against the ball's current position, `swos.asm:100883-100912`) — whichever of two mutually exclusive outcomes fires first (`swos.asm:115828-115931`):

- **Connects with the ball:** wins it outright, deterministically, no matter the approach angle — a slide that reaches the ball from directly behind is just as clean as one from the front. This path never runs a foul check at all.
- **Misses the ball, collides with the opponent instead:** checked for a foul (`PlayerTacklingTestFoul`, `swos.asm:106973-107255`) via a direction-match check — the tackler's own movement direction compared against the tackled player's. A close match (within ±1 on the direction scale, i.e. closing from behind, moving the same way the opponent was facing) concedes a foul; a large enough difference is a clean challenge. Two override states on the tackler's `tackleState` field can skip the direction check entirely: one always concedes a foul, one (`TS_GOOD_TACKLE`) is always clean.

The two combine into a real-world asymmetry: a defender chasing directly behind a dribbler is chasing a ball sitting at the *attacker's* feet, ahead of the defender's own sprite — closing to within 8 pixels from directly behind means nearly closing the gap entirely first. A side-on or front-on challenge is far likelier to catch a moment where the ball passes that close to the challenger's own sprite. So a same-direction chase from behind overwhelmingly lands in the "missed the ball" branch — exactly the branch the direction-match check flags as a foul. The rule doesn't penalize the angle directly; the geometry of a trailing chase just rarely produces a clean connect in the first place.

**After any tackle attempt**, the tackling player is left lying on the ground; Tackling skill sets how long, on a clean linear scale (`SetPlayerDowntimeAfterTackle`, `swos.asm:105160-105184`, `kPlayerTacklingDownTime`: 30 frames at Tackling 0 down to 9 frames at Tackling 7 — 3 frames faster per skill point). A CPU-initiated tackle uses a flat 3-frame recovery instead, Tackling skill irrelevant (`kComputerTacklingDownTime`) — human and AI tackling recover under genuinely different rules.

#### Fouls, Cards & Injuries

A foul always results in a stoppage — a penalty or free kick either way, decided independently of any card outcome (`TestFoulForPenaltyAndFreeKick`, called unconditionally regardless of what follows, `PlayerTacklingTestFoul`, `swos.asm:107252-107254`). Whether it also draws a card is gated first by a timer-jittered check against `playerCardChance`, a configurable per-match setting — missing that gate means no card at all.

**Where the foul happens changes the odds.** Inside the penalty box (`swos.asm:107102-107119`), the standard roll applies: roughly 12.5% straight red, 87.5% yellow (`swos.asm:107220-107234`). Outside the box, the engine first checks for cover — comparing the tackler's own closest teammate's distance to the fouled player against the fouled player's own distance to goal (`swos.asm:107121-107212`). If no teammate was closer than the goal itself — nobody covering, a last-man situation — the odds invert to roughly 87.5% straight red / 12.5% yellow instead (`swos.asm:107237-107249`); otherwise it's the same standard roll.

**A second yellow card in the same match is an automatic sending-off**, explicitly modeled (`TryBookingThePlayer`, `swos.asm:107398-107444`): a player's per-match card count is tracked directly, and hitting 2 produces a distinct `CARD_SECOND_YELLOW` outcome — reversing the earlier booking tally, counting it as a sending-off instead, and drawing down the team's shared injury/dismissal budget (see below).

**Injuries are rolled independently of the foul/card outcome**, on every tackle collision regardless of whether it's later ruled clean or a foul (`PlayerTackled`, `swos.asm:107843-108019`, called before any card logic runs). Each team draws from a shared budget (`team1NumAllowedInjuries`/`team2NumAllowedInjuries`, also drawn down by a second-yellow send-off above) — once it hits zero, no further injuries or send-offs can occur that match. While the budget allows it:

- The chance of any injury is scaled by the match-length setting (`kTackleInjuryProbability`: 18.75%, 10.9%, 7.8%, 5.5% per tackle across four settings — decreasing as matches get longer, keeping total expected injuries per match roughly stable) and **roughly doubles for a player already carrying an injury** (`kTackleInjuryProbabilityAlreadyInjured`: 37.5%, 22.3%, 16.0%, 10.9%).
- Severity, when an injury occurs, is a weighted roll across 7 levels (`kInjuryLevels`: weights 42/7/5/4/3/2/1 out of 64 — the mildest "knock" alone accounts for ~66%). **An already-injured player's roll shifts hard toward the severe end** (`kInjuryLevelAlreadyInjured`: weights 14/15/12/9/7/5/2 out of 64 — the mildest outcome drops to ~22%) — quantifying what the Jon Hare Q&A only implied (see [Career Mode Mechanics](career-mode-mechanics.md)).

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

**The pitch is 672 × 848 pixels; the screen is 320 × 200.** The screen dimensions are mode 13h, set at `swos-port/swos/swos.asm:7276` and corroborated by the 64000-byte framebuffer clear at `swos.asm:14562` and by `WIDTH`/`HEIGHT` in `tools/swospp/main/swos.h:13-14`. The pitch comes from `PITCH_W`/`PITCH_H` in `tools/swpe/src/h/pitch.h:7-8`, tiled from 16-pixel patterns (`tools/swpe/src/h/pattern.h:8`). The engine's own out-of-bounds check agrees on width — `cmp word ptr D0, 672` under the comment *"keep increasing until one goes out of pitch bounds"* (`swos.asm:108471`) — but pairs it with **880** rather than 848 on the y axis two lines later, which is likely playing surface versus tiled area including margin behind the goals, and is not yet confirmed.

Consequences, since they are easy to get wrong from screenshots:

- **The view scrolls on both axes.** The pitch is 2.1× wider and roughly 4.2× taller than the screen, so about **11%** of it is visible at once — 47.6% of the pitch's width against 23.6% of its length. Nothing like the whole pitch is on screen, and the window is far wider relative to the pitch than it is long.
- **The pitch is portrait**, taller than it is wide, matching the vertical attacking orientation the manual describes.
- **Speeds elsewhere in this document are in these pixels.** A Speed-7 player's 2.44 px/tick crosses the 672-pixel width in about 275 ticks, a little under five seconds at 60fps.

### Engine Performance

- **High frame rate, frantic pace.** The engine runs at 60 frames per second, which is credited directly for the game's snappy feel; online latency is what breaks it. There are zero long animations to wait out, and players can pivot instantly — the game leans on raw reflexes, prediction, and quick execution rather than animation-driven timing.
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

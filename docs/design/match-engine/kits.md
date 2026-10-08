# Kits

A team has two kits, drawn by recolouring shared art; when two teams' kits read too alike, a fixed order of fallbacks picks what each wears. Which side a player is on has to read at a glance, at play size.

## Kit Data

- **A team has two kits, primary and secondary.** A kit is a shirt type and four colours — shirt, second shirt colour, shorts, socks — from a palette of ten: grey, white, black, orange, red, blue, brown, light blue, green, yellow
- **Four shirt types:** plain, contrasting sleeves, vertical stripes, horizontal stripes. A plain shirt ignores its second colour
- **Every keeper wears the same near-black shirt**, outside the kit palette, with their team's shorts and socks from whichever kit it is wearing
- **Colours only.** A real club's colours are fine on their own, per [Real Football](../../decisions/licensing-and-ip.md#real-football)

*Derived from: Kits, [Match Mechanics](../../../sources/swos/match-mechanics.md#kits).*

## Recolouring

- **Recoloured by palette swap, never drawn per kit.** Kit regions — shirt, second shirt colour, shorts, socks — are drawn in reserved colours and swapped for the kit's at match start. Sideloaded sprites already use the reference's reserved colours; placeholders and the project's own art use the same ones
- **A plain shirt reuses the vertical-stripe art** with both shirt colours the same, so three sets of shirt art serve four shirt types
- **The keeper's shirt is drawn in a fixed colour**, not the reserved ones, since it is never recoloured

**Acceptance criteria:**

- Changing a team's kit data changes every sprite of that team, with no art touched

*Derived from: Kits, [Match Mechanics](../../../sources/swos/match-mechanics.md#kits).*

## Clashes

- **Clashes are scored, not looked up.** Two kits score points for each pair of colours that read alike — shirt against shirt, second colour against shorts; socks never count — and a score at or past a threshold is a clash. The pairs, weights and threshold are data, taken from the reference
- **The first combination that doesn't clash is worn:**
  1. Both primaries
  2. The second-named team in its secondary
  3. The first-named team in its secondary, the second in its primary
  4. Both secondaries
  5. The second team in a single colour — shirt, shorts and socks — trying its own kits' colours in turn against the first team's primary: primary second colour, shirt and shorts, then the secondary's
  6. The second team in a single colour from a fixed order: red, blue, white, light blue, yellow, grey, orange, brown, green, black
  7. The first team all red and the second all blue, both in white shorts

**Acceptance criteria:**

- For any two teams, the kits worn are the first combination in the order above that doesn't clash — exact tests against the reference's tables

*Derived from: Kits, [Match Mechanics](../../../sources/swos/match-mechanics.md#kits).*

## Acceptance Criteria

- At the Deck's scale, a player's side reads without a second look — your outfield kit, the opposition's and both keepers', mid-tackle included. Judged by eye

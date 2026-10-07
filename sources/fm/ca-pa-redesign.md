# Rethinking CA/PA: A Simulated Player Development Model

A redesign sketch written against FM's model, kept as research. It is not a description of FM, and not a plan for this game. What we took from it is in [Player Depth](../../project/ideas/player-depth.md). The claims in §1 about how FM behaves are unchecked, like the rest of [Player Attributes](player-attributes.md).

A design sketch for replacing Football Manager's Current Ability / Potential Ability
system with a more organic, attribute-level simulation — starting from specific
problems in the existing model and working toward a fuller redesign.

## 1. The problem with the current model

FM's CA/PA system works like this: CA is a weighted sum of visible attributes
(weights vary by position), and PA is a hard ceiling CA can never exceed. This
produces two recurring issues:

- **Position/attribute mismatches.** Newgens can be generated with a position tag
  that's decoupled from their attribute profile — a "right winger" spawning with
  centre-back-tier tackling and marking. Position and attributes aren't derived
  from each other; they're rolled somewhat independently.
- **Counterintuitive costing.** Because CA weights reflect *relevance to a
  position* rather than *rarity or value*, attributes outside a player's position
  are cheap to raise, not expensive — the opposite of what intuition suggests.
  Raising a striker's tackling barely moves his CA, since tackling barely counts
  toward "how good is this striker," which makes off-role stat-stacking a known
  exploit rather than a deliberate design choice.
- **One undifferentiated ceiling.** A single PA number governs every attribute at
  once, even though physical and footballing skills behave completely
  differently in real development — sprint speed is largely fixed by genetics,
  while technical skill and football intelligence remain highly trainable well
  into a player's late 20s and 30s.

## 2. Fix generation order: attributes → position → CA (not the reverse)

Rather than assigning a target CA/PA and back-filling attributes to match, flip
the pipeline:

1. Generate a raw skill profile first.
2. Derive which position(s) that profile actually suits, using the same
   weighted-sum math already used for CA.
3. Let CA fall out of that calculation as an output, not an input.

This mirrors how real players are already handled — researchers rate attributes
from observation, and CA is computed from that, not the other way around. It
also structurally eliminates the mismatch problem: a player's listed position
becomes whatever his stats best support, so a "winger" with centre-back
attributes can't occur.

Two knock-on requirements:
- **Investment still needs to matter.** Better facilities/coaching should bias
  the *raw attribute rolls* toward a higher mean, rather than setting a CA target
  directly — noisier, but preserves the incentive to invest in youth setup.
- **PA needs its own generation.** Project a *peak* profile (what the player
  could grow into, influenced by youth quality) separately from the *current*
  profile — current profile yields CA, projected peak yields PA.

## 3. Controlled scarcity for elite talent

Pure randomisation (even from a long-tailed distribution) gives unreliable
year-to-year outcomes — some years zero standout talents, some years several,
by chance alone.

Instead: generate a **bounded discrete count of "superstar slots" per intake**
(e.g. sampling a small number, capped 0–5), each independently rolled to fire.
This gives genuine variance — some years produce none — without the wild,
unbounded swings a raw statistical tail can throw, and keeps the global talent
pool self-regulating over a decades-long save.

Each fired slot then:
1. Rolls a coherent **archetype template** (poacher, box-to-box engine,
   sweeper-keeper) rather than just maxing random attributes — avoiding
   incoherent freaks (max pace + max jumping + max long throws on one frail
   winger).
2. Goes through a **two-stage weighted draft**: nation-level weighting first
   (reputation, population, football development), then club-level weighting
   within that nation (facilities, coaching, recruitment) — keeping each layer
   independently tunable.
3. Retains a **small residual chance of landing anywhere**, so the next great
   player turning up in a footballing backwater stays possible, just much less
   likely than at a super-academy. Mild diminishing returns on facility
   weighting (or a temporary penalty for recently-successful academies) keeps
   the same 3–4 clubs from monopolising every generation indefinitely.

## 4. Decouple physical ability from footballing ability

Physical and footballing/technical skills don't behave the same way over a
career, so they shouldn't share one ceiling or one growth rate:

| | Physical | Footballing / Technical |
|---|---|---|
| **Ceiling** | Largely genetic; narrow trainable band | Wide trainable band; skill can climb for years |
| **Growth driver** | Age, natural conditioning, marginal technique gains | Training hours, coaching quality, match experience |
| **Peak age** | Early-to-mid 20s | Late 20s to early 30s |
| **Decline** | Starts earlier, often steeper | Slower; can be offset by accumulated game intelligence |

This is what allows a "Messi" outcome to make sense mechanically: modest physical gifts, weighted against a much wider and
higher-climbing footballing ceiling, still nets out to a generational player.

**Mental attributes are an awkward middle case.** Decisions, anticipation, and
composure aren't purely coached — they respond more to match minutes and big-game
exposure than to training-ground hours. Best modelled inside the footballing
bucket, but with *experience* as their primary growth input rather than
training intensity — a player who trains brilliantly but rarely plays develops
technique without game-smarts, and vice versa.

## 5. Replace CA/PA entirely with per-attribute simulation

Taken to its logical end: don't decouple into two buckets — give **every
attribute its own growth curve**, and make CA/PA downstream forecasts rather
than causal inputs. (Out of the Park Baseball does a version of this: every
skill has an independent, age-based growth curve, and "potential" is a
projection computed from those curves rather than a developer-set number.)

Key pieces:

- **Ceilings become emergent, not stored.** Each attribute grows via a
  diminishing-returns curve (logistic/S-curve) around a hidden per-attribute
  talent coefficient. There's no PA check to hit — growth just becomes
  negligible as the curve flattens near its asymptote. This also naturally
  encodes "some players are just better": draw talent coefficients from an
  unequal, long-tailed distribution, and imbalance falls out of generation
  rather than needing a separate mechanic to enforce it.
- **Use correlated latent factors, not fully independent attribute rolls.**
  A handful of hidden traits — e.g. **Athleticism, Football IQ, Technical Gift,
  Competitiveness** — each pull on a weighted cluster of attribute ceilings.
  This keeps generated players coherent (a physical freak has pace, power, and
  jumping rise together; a low-mobility playmaker has Technical Gift and
  Football IQ elevated with ordinary Athleticism) instead of producing
  statistical noise with no discernible "shape." It also cleanly reproduces the
  physical/footballing split from Section 4 as two (or more) of these factors,
  each with its own trainability and age curve.
- **Scarcity moves from CA points to training time.** With no shared CA budget
  forcing trade-offs, something else has to make improvement finite: finite
  weekly training hours/attention. The manager now allocates limited coaching
  focus across attributes, which is arguably a richer decision surface than a
  single CA balancing lever.
- **Scouting becomes a projection, not a hidden-number reveal.** Forecast each
  attribute's curve forward N years from its current trajectory, sum through
  position weighting, and present that as the scouted "potential." Scouting
  quality determines how well a scout reads the trajectory — same gameplay
  feel as today's star-rating uncertainty, now causally grounded in something
  actually simulated.

## 6. What this costs

- Tuning burden increases substantially: one CA curve becomes dozens of
  attribute-level curves × age modifiers × position/role interactions, with no
  single elegant lever left for "is this player developing at the right pace."
- Requires a new scarce resource (training time/attention) to preserve
  meaningful trade-offs, since the shared CA budget is gone.
- Needs a redesigned scouting/projection layer to replace the simple CA/PA
  numbers players are used to reading.

Worth it if the goal is a genuinely simulated, realistic development model with
richer scouting and coaching decisions. Not worth it if the only goal is fixing
the position-mismatch bug — the generation-order fix in Section 2 solves that
on its own, at a fraction of the complexity.

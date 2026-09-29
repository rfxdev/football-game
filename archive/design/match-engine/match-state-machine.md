# Match State Machine

kickoff, set pieces, throw-ins, corners, referee logic

## Match Clock and Periods

- Free kicks and goal kicks fold into "set pieces" above, and goals are an event the referee logic detects. **Half-time does not fit either** — it is the match as a whole having structure, not a restart within play
- Implies things no other doc currently owns: a match clock, its speed relative to real time, periods (first half, half-time, second half, full time), and the transitions between them
- Half-time also means state that has to survive the break — score, and eventually possession stats or anything the tournament layer wants. [CPU vs CPU Simulation](../tournament-and-career-mode/cpu-vs-cpu-simulation.md) is the likely consumer of whatever a finished match reports
- The clock is a feel decision as much as a rules one: how long a "90 minutes" takes in real time sets the pace of a session, and short halves are the norm in arcade football for good reason

## Open Questions

- How long is a half in real time, and is that player-configurable?
- Does the clock stop for set pieces and goals, or run continuously?
- Is half-time a pause with a swap of ends, or purely a state transition with no presentation attached at this stage?

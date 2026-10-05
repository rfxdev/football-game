# Build Pipeline (Windows or macOS → Steam Deck / Linux)

Getting a build off the dev machine — a Windows PC or the MacBook — and onto the Deck. [Roadmap](../project/roadmap.md) covers *when* — at phase boundaries, and never for something the editor can show you, per [Playtesting](playtesting.md). This doc covers *how*.

Two targets, for different reasons: **the dev machine's own OS** is a local integration check, needing no signing or notarisation for a personal dev loop; **Linux x86_64** is the Steam Deck build, and the one that can surprise you.

Near-zero friction on this path was the deciding factor for Godot over Unity in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md). This is where that claim gets cashed in.

## Export Templates (One-Time Setup)

- Godot needs **export templates** — prebuilt engine binaries for each target platform. Editor → Manage Export Templates
- **They must match the editor version exactly**, including the build suffix. Upgrading Godot means re-downloading templates, and a mismatch fails at export time rather than silently producing something odd
- One download covers every platform *and* both debug and release variants. There is no per-platform module to install and no scripting backend to choose
- Per machine — Windows and the MacBook each need their own download, at the same editor version

## Debug vs Release Exports

- **Debug export** — verbose errors, stack traces on crash, and it can attach back to the editor's debugger over the network. This is the iteration build
- **Release export** — stripped and optimised; what you'd distribute
- **Remote debugging is the underrated part:** a debug build running on the Deck can connect to the editor on the dev machine over the network, so a Deck-only bug is diagnosable with the same debugger and remote scene tree as the local loop, rather than by print statements and guesswork. The exported binary takes a remote-debug host argument (`--remote-debug tcp://<dev-machine-ip>:<port>`) — confirm the exact form for the Godot version in use
- Default to debug builds while iterating, but **use a release build for anything performance-related**. Debug builds are slower and will misrepresent what the Deck can do

## Cross-Export

- Export templates are prebuilt binaries, so producing a Linux x86_64 build on Windows or an ARM Mac is just Godot packaging your project alongside a prebuilt x86_64 engine binary. No cross-compiler toolchain, no VM required to *produce* the artefact
- Target **Linux x86_64** — the Deck is x86_64, not ARM

## Intermediate Check: Linux VM

- A Linux guest as a sanity check before touching real hardware. Catches API and file-path problems; it will tell you **nothing useful about performance**
- **Windows:** WSL2 with an Ubuntu guest runs the actual x86_64 artefact natively, and WSLg shows its window
- **Mac:** UTM with an Ubuntu guest. An ARM guest runs natively and fast, but then you aren't running the x86_64 binary you'll ship. Running the actual artefact needs x86 emulation, which is slow — acceptable, because the question being asked is "does it start and find its files", not "what framerate"
- Optional. Its value is catching a stupid path bug without a round trip to hardware; skip it if you'd rather go straight to the Deck

## Getting It Onto the Deck

No Steam listing required — Developer Mode is enough:

1. Enable **Developer Mode** in Steam Deck settings
2. Enable **SSH**, then `scp` the build across. Alternative: USB-C hub and a USB drive
3. Switch to **Desktop Mode** (power menu) and open a terminal
4. `chmod +x ./YourGame && ./YourGame`

- The executable bit is the classic stumble — it doesn't reliably survive transfer, particularly via exFAT USB drives. A binary that appears to do nothing is usually this
- **SSH remote deploy** in the Linux export preset can replace steps 2–4 for debug builds: one click in the editor copies the build to the Deck and runs it, attached to the debugger. Confirm the option for the Godot version in use
- To exercise Gaming Mode and Steam Input rather than just the binary, add it as a non-Steam game on the Deck instead of launching from a terminal — see [Gamepad Input and Steam Deck Parity](gamepad-input-and-steam-deck-parity.md)

## Sideloaded Art

Exports never carry it, by construction — see [Local Data](../docs/decisions/licensing-and-ip.md#local-data). Each machine that runs the game needs its own copy in `user://`, once, and again only when the art changes:

| Machine | `user://` |
| --- | --- |
| Deck (Linux) | `~/.local/share/godot/app_userdata/<project name>/` |
| Windows | `%APPDATA%\Godot\app_userdata\<project name>\` |
| macOS | `~/Library/Application Support/Godot/app_userdata/<project name>/` |

- A custom user directory in Project Settings changes these paths; the editor's Project → Open User Data Folder shows the current one
- A Deck without it should show the placeholders, not fail — worth confirming on the first Deck run
- The case rule below applies to these filenames too

## What to Verify on Real Hardware

At each phase boundary, per [Roadmap](../project/roadmap.md) — not every iteration:

- **Performance at 1280×800**, using a release build, and ideally on battery — the Deck throttles under power constraints in ways a desk-bound test won't show
- **Gamepad input end to end.** Everything in the parity doc is a well-founded assumption until it has run on the actual device
- **No Linux-specific path issues** — see below
- **How the UI reads at 7 inches.** Legibility at that physical size is not something the Game view can answer

## Case Sensitivity — The One That Will Bite

- Windows and macOS filesystems are case-insensitive by default; Linux is case-sensitive. `sprites/Ball.png` and `sprites/ball.png` are one file on the dev machine and two different files on the Deck
- In Godot this surfaces as `res://` paths that work perfectly in the editor and fail on the Deck: `load()` returns null, scenes open with missing textures, and nothing looked wrong locally. It is a genuinely miserable debugging session if it arrives alongside other changes
- **Enforce consistent casing from day one.** Lowercase with underscores for every file and directory, matching Godot's own file naming convention
- Worth an automated check rather than vigilance — see [Automation Testing](automation-testing.md). It's the cheapest possible CI job and it catches the exact class of bug that's hardest to find by hand
- Fixing casing later is awkward on a case-insensitive filesystem — git often won't register the rename. A two-step rename through a temporary name works

## Proton

- Not needed. The build is Linux native
- Worth knowing as a **diagnostic**: if a Linux build has a stubborn issue, running a Windows export through Proton isolates whether the problem is the game itself or something specific to the Linux binary

## Open Questions

- Does CI ever produce exports (headless `--export-release`), or stay lint-and-test only?
- What's the Deck performance target — locked 60fps at 1280×800, and what battery life is acceptable alongside it?
- Is the Linux VM step worth setting up at all, or is the Deck round trip cheap enough to skip it?
- Does the remote debugger actually reach the Deck over the local network without firewall fiddling? Worth confirming during the first pipeline run, while nothing else is in flight

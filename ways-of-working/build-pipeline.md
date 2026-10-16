# Build Pipeline (Windows or macOS → Steam Deck / Linux)

Getting a build off the dev machine — a Windows PC or the MacBook — and onto the Deck. [Roadmap](../project/roadmap.md) covers *when* — at phase boundaries, and never for something the editor can show you, per [Playtesting](playtesting.md). This doc covers *how*.

Two targets, for different reasons: **the dev machine's own OS** is a local integration check, needing no signing or notarisation for a personal dev loop; **Linux x86_64** is the Steam Deck build, and the one that can surprise you.

Near-zero friction on this path was the deciding factor for Godot over Unity in [Technical Architecture and Stack](../docs/decisions/architecture-and-stack.md). This is where that claim gets cashed in.

## Export Templates (One-Time Setup)

- Godot needs **export templates** — prebuilt engine binaries for each target platform. Editor → Manage Export Templates
- **They must match the editor version exactly**, including the build suffix. Upgrading Godot means re-downloading templates, and a mismatch fails at export time rather than silently producing something odd
- **Pick the platforms you build for** — the download offers each OS and architecture separately, each covering debug and release. Linux x86_64 is the Deck's; the dev machine's own is the local check. Nothing needs the 32-bit or the Windows and Linux arm64 ones. There is no scripting backend to choose
- Per machine — Windows and the MacBook each need their own download, at the same editor version

## Debug vs Release Exports

- **Debug export** — verbose errors, stack traces on crash, and it can attach back to the editor's debugger over the network. This is the iteration build
- **Release export** — stripped and optimised; what you'd distribute
- **Remote debugging is the underrated part:** a debug build running on the Deck can connect to the editor on the dev machine over the network, so a Deck-only bug is diagnosable with the same debugger and remote scene tree as the local loop, rather than by print statements and guesswork. The exported binary takes a remote-debug host argument (`--remote-debug tcp://<dev-machine-ip>:<port>`) — confirm the exact form for the Godot version in use
- Default to debug builds while iterating, but **use a release build for anything performance-related**. Debug builds are slower and will misrepresent what the Deck can do

## Cross-Export

- Export templates are prebuilt binaries, so producing a Linux x86_64 build on Windows or an ARM Mac is just Godot packaging your project alongside a prebuilt x86_64 engine binary. No cross-compiler toolchain, no VM required to *produce* the artefact
- Target **Linux x86_64** — the Deck is x86_64, not ARM

## What Goes in the Build

Exporting all resources takes everything the editor imports. What stays out is decided by who needs it:

- **Godot never needs it → a `.gdignore` in the folder.** Docs, research, recordings, builds, test reports. The editor never scans or imports it, so nothing in it can reach an export, by construction — an image left in `sources/` or `recordings/` included. A gitignored folder commits its `.gdignore` through an exception in `.gitignore`
- **The editor needs it, the game doesn't → the preset's exclude filter.** `test/*, addons/gdUnit4/*` — ignored, the suite couldn't run. A build carrying GdUnit4 would also owe its licence notice, per [Third-Party Intake](../docs/decisions/licensing-and-ip.md#third-party-intake). Every preset needs the filter, so check a new one's Resources tab
- Files at the root can't be ignored one by one. They're Markdown and config, which export skips anyway

## Intermediate Check: Linux VM

- A Linux guest as a sanity check before touching real hardware. Catches API and file-path problems; it will tell you **nothing useful about performance**
- **Windows:** WSL2 with an Ubuntu guest runs the actual x86_64 artefact natively, and WSLg shows its window
- **Mac:** UTM with an Ubuntu guest. An ARM guest runs natively and fast, but then you aren't running the x86_64 binary you'll ship. Running the actual artefact needs x86 emulation, which is slow — acceptable, because the question being asked is "does it start and find its files", not "what framerate"
- Optional. Its value is catching a stupid path bug without a round trip to hardware; skip it if you'd rather go straight to the Deck

## Getting It Onto the Deck

No Steam listing and no console — a non-Steam shortcut in Gaming Mode, set up once:

1. **Copy the build across** — an exFAT USB drive through a USB-C adapter, or `scp` over the local network. A cable to the PC doesn't work: the Deck's port is a host, not a drive
2. In **Desktop Mode** (power menu), copy it into the home folder with Dolphin, then Properties → Permissions → **Is executable**
3. Steam → Games → **Add a Non-Steam Game** → browse to it. It runs the main scene: export templates refuse a scene path on the command line, though the editor binary takes one
4. Launch from the library in **Gaming Mode**. The Steam button's **Exit Game** quits it, and the Performance overlay shows the frame rate

- **The executable bit doesn't survive a FAT or exFAT copy.** Re-tick it after copying a new build over the old one. A binary that appears to do nothing is usually this
- **Gaming Mode is the run, not the terminal.** It's where Steam Input is in the path, per [Deck Input Parity](deck-input-parity.md), and the only place a fullscreen export can be left — the game has no quit of its own until it has a front end. Launched from Desktop Mode, Steam + X's keyboard has Alt+F4
- **SSH needs only the local network.** Set the `deck` user's password with `passwd`, then `sudo systemctl start sshd`. A Wi-Fi extender can keep the two apart; the USB drive doesn't care
- **SSH remote deploy** in the Linux export preset can replace steps 1–4 for debug builds: one click in the editor copies the build to the Deck and runs it, attached to the debugger. Unconfirmed — the first run had no network to try it on

## Sideloaded Art

Exports never carry it, by construction — see [Local Data](../docs/decisions/licensing-and-ip.md#local-data). Each machine that runs the game needs its own copy in `user://`, laid out per [Sideloaded Art](../docs/design/match-engine/sprites.md#sideloaded-art), once, and again only when the art changes:

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
- Worth an automated check rather than vigilance — the first CI job, per [Automation Testing](automation-testing.md#ci). It's the cheapest possible: any Linux runner catches it simply by loading the project, and it catches the exact class of bug that's hardest to find by hand
- A pre-commit hook already rejects capitals and spaces in non-doc paths, per [Automation Testing](automation-testing.md#tooling). It keeps filenames right, not the `res://` paths that reference them, so the CI job still earns its place
- Fixing casing later is awkward on a case-insensitive filesystem — git often won't register the rename. A two-step rename through a temporary name works

## Proton

- Not needed. The build is Linux native
- Worth knowing as a **diagnostic**: if a Linux build has a stubborn issue, running a Windows export through Proton isolates whether the problem is the game itself or something specific to the Linux binary

## Open Questions

- Does CI ever produce exports (headless `--export-release`), or stay lint-and-test only?
- What's the Deck performance target — locked 60fps at 1280×800, and what battery life is acceptable alongside it?
- Is the Linux VM step worth setting up at all, or is the Deck round trip cheap enough to skip it? The first run skipped it; its one surprise, the refused scene path, was the template's, which a local export of the dev machine's own OS catches too
- Does the remote debugger actually reach the Deck over the local network without firewall fiddling? The first pipeline run had no network to try it on
- How does a Deck build reach more than one scene, or more than one scenario in the sandbox? It runs only the main scene, as saved. Answer it at the first phase boundary with more than one thing to look at on the Deck

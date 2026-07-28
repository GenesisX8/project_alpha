# Project Alpha — CLAUDE.md

Godot 4.7.1 (standard build), 2D pixel-art tactical turn-based RPG. Single-player, PC desktop only (Windows/Mac/Linux) for v1.

Full design context lives in [docs/design/](docs/design/) — read those before making gameplay/rules decisions. This file is technical/process guidance only.

## Core concept (locked in)

- **Combat**: Traditional stationary-party JRPG-style battles (Final Fantasy / Dragon Quest era) — characters do **not** move on a spatial grid. An earlier draft implied grid-based tactics; that direction was explicitly dropped.
- **Battle layout**: party renders on the **LEFT**, enemies on the **RIGHT** — deliberately mirrored from FF6, which was authored for right-to-left reading order.
- **Party**: Full party of multiple player-controlled characters vs. a group of enemies (not a single hero).
- **Turn order**: dynamic, Speed/Agility-stat-based (recomputed each round — classic Final Fantasy style), not a fixed party-then-enemies alternation.
- **Actions**: Each character's turn uses a standard JRPG action menu (Attack / Skill / Item / Defend) **plus** an optional "Play Card" — playing a card can combine with a standard action rather than consuming the whole turn.
- **Cards**: One **shared party deck/hand** (not per-character) supplies *additive* special effects — spells, buffs, traps — plus resource cards that fill a chosen character's own resource pool (each character has their own resource type, e.g. Mana vs. Rage). The player builds their own deck — this is a real deckbuilding meta-layer, not a fixed loadout. See `scripts/card.gd`, `scripts/player_deck.gd` (note: `PlayerDeck`'s current per-`CharacterBody2D` attachment needs to move to a party-level owner now that the shared-deck model is confirmed).
- **Card interactions**: a full MTG-style priority/interrupt stack — a deliberate, high-scope commitment. Build it incrementally (immediate resolution → conditional triggers → full stack); see [docs/design/build-plan.md](docs/design/build-plan.md#5-effect-ability-system-and-the-interrupt-stack).
- **Win/loss**: all enemies defeated = win; whole party downed simultaneously = loss. Downed characters are revivable mid-battle (not permanently removed). No escape/turn-limit/objective battle variants for now.
- Full detail, plus what's still genuinely open (party size/roster, progression systems, narrative, art pipeline, exact tuning numbers): see [docs/design/gdd.md](docs/design/gdd.md) and [docs/design/rules.md](docs/design/rules.md).

**Do not assume answers to open questions** (marked as such in the design docs). Ask before implementing something that depends on one.

## Tech stack

- **Engine**: Godot 4.7.1, **standard build** — *not* the Mono/.NET build. There is no `.csproj`/`.sln` and `config/features` does not include `"C#"`.
- **Language: GDScript, exclusively.** C# is not available in this project — **do not add C# scripts or suggest a C# port.** The project previously had stray C# stub files (`NewScript.cs`) that were deleted; treat that as confirmation GDScript is the intended path.
- Physics is left at Godot defaults (`Jolt Physics` for 3D) — irrelevant to this 2D game's logic, not a deliberate choice.
- Rendering: Forward+, `d3d12` device driver on Windows (editor/local machine default, not a shipping decision yet).
- Godot editor path for VS Code is configured in `.vscode/settings.json` (`godotTools.editorPath.godot4`) — keep that in sync if the editor install moves. Note that `.vscode/` is gitignored (except `extensions.json`), so this path is machine-local and not shared.
- **.NET/C# was removed — this is settled** (2026-07-26). The project was originally created with the Mono/.NET editor build by mistake; .NET was subsequently stripped and the standard build is now correct. Use the standard Godot 4.7.1 build on every machine. Don't propose reintroducing C#/Mono unprompted.

## Tooling

- **Linting**: `gdlint` (gdtoolkit 4.5.0, installed via `uv tool install gdtoolkit`). Run `gdlint scripts/*.gd` — it verifies the conventions below mechanically. **Do not run `gdformat`**: gdtoolkit's last release was Oct 2025 and it has open bugs where the formatter emits indentation Godot rejects ([#424](https://github.com/Scony/godot-gdscript-toolkit/issues/424), [#417](https://github.com/Scony/godot-gdscript-toolkit/issues/417)). Fix lint findings by hand.
- **Testing**: none set up yet. gdUnit4 is the intended framework, but its latest *stable* release (v6.1.3) supports only Godot 4.5–4.6.3 — **4.7 support exists only on the unreleased master/v6.2 branch**. Revisit when v6.2 ships or when the rules engine (build-plan step 3) lands.
- **MCP: none, deliberately** (evaluated 2026-07-24). [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) was installed and then removed: it requires an addon in `addons/`, which forces an `[editor_plugins]` entry and an autoload into `project.godot`. Either vendor 1.8 MB / 245 files into the game repo, or leave `project.godot` pointing at a gitignored path (measured: 3 non-fatal startup errors, game still runs). Neither is worth it yet — the headless `godot` CLI below already covers validation and testing, and live scene-tree/screenshot tooling only pays off at build-plan steps 6/9 (UI work). **Revisit then**, not before. [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) is the addon-free alternative if the repo footprint is the blocker, but it was 3 months stale with no stated 4.7 support.
- **Headless checks** (fast, no editor window):
  - `godot --headless --path . --quit` — imports the project and surfaces parse/load errors.
  - `godot --headless --path . --import` — rebuilds `.godot/` caches. **Needed after renaming any script**: Godot resolves `ext_resource` by `uid://` first, so a stale `.godot/uid_cache.bin` keeps pointing at the old path even after the `.tscn` is updated. This **also compiles shaders** and prints `SHADER ERROR:` on failure — the only way to validate a `.gdshader` without opening the editor.
  - `godot --headless --path . res://scenes/Foo.tscn --quit-after 5` — instantiates one scene for a few frames. Surfaces missing resources and bad node paths. Note it uses a dummy renderer, so it does *not* validate shaders; use `--import` for that.

## Where things live

- `scripts/` — GDScript source. Card data model (`card.gd`), deck/hand management (`player_deck.gd`), scene controllers (`game_controller.gd`, `player_script.gd`).
- `scenes/` — `.tscn` scene files. `BattleScene.tscn` is the battle-screen mock-up (layout, background, placeholder actors — no logic wired yet); `Prototype2D.tscn` is the older logic-node prototype.
- `cards/` — `.tres` `Card` Resource instances (data, not code) — e.g. `card_fireball.tres`, `card_frostbolt.tres`. This is the card database; expect it to grow significantly and eventually need an import/editor pipeline (see build plan).
- `assets/` — art assets, by role: `backgrounds/`, `actors/heroes/`, `actors/enemies/`, `vfx/`. Replaced the old `sprites/` folder (deleted 2026-07-26 with its unused `chibi_player.svg` placeholder). Art direction and locked pixel constants live in [gdd.md](docs/design/gdd.md#battle-scene-presentation) — **party renders on the LEFT, enemies on the RIGHT** (mirrored from FF6 on purpose).
- `shaders/` — `.gdshader` files, `snake_case`, one effect per file. Keep them here rather than embedded in `.tscn` sub-resources: they stay reusable across scenes and readable in a diff. Catalogued in [docs/tech/vfx-catalog.md](docs/tech/vfx-catalog.md), which also lists the sprite-authoring rules several of them depend on.
- `docs/design/` — **canonical, living design documentation.** Update these as decisions are made in conversation.
- `docs/tech/` — technical reference that isn't a design decision (shader catalogue, pipeline notes).
- `documents/` — **gone.** Held legacy plain-text notes (`Game Design.docx`, `Rules.docx`, `Game Build.docx` — plain text despite the extension); deleted from the repo once their content was migrated into `docs/design/`. The "Migrated from `documents/…`" lines at the top of the design docs are provenance notes, not live paths.

No task tracker is set up yet (deliberately — revisit later if needed). Roadmap/milestones live inline in `docs/design/build-plan.md`.

## GDScript conventions

Follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

- **Files & folders**: `snake_case` (e.g. `player_script.gd`).
- **Classes / `class_name`**: `PascalCase` (e.g. `class_name PlayerDeck`).
- **Node names** (in scenes): `PascalCase`.
- **Functions & variables**: `snake_case`.
- **Constants**: `CONSTANT_CASE`.
- **Signals**: `snake_case`, past tense (e.g. `signal deck_loaded`, `signal card_played`).
- **Enums**: `PascalCase` name, `CONSTANT_CASE` members.
- **Private members**: prefix with a single underscore (`_current_hand`).
- **Indentation**: tabs, not spaces. This project's `.editorconfig` doesn't currently pin this — GDScript's own toolchain (and Godot's own file writes) defaults to tabs; don't fight it.
- **Static typing**: use explicit types when not obvious (`var health: int = 0`), inferred typing (`:=`) when the right-hand side makes the type clear, and always type `get_node()` results explicitly (inference can fail there).
- **Booleans**: use `and` / `or` / `not`, not `&&` / `||` / `!`.
- **Strings**: double quotes by default.
- **File member order**: `@tool`/annotations → `class_name`/`extends` → docstring → signals → enums → constants → exported/public vars → private vars → `_init()` → `_ready()` → other virtual callbacks → public methods → private methods → inner classes.
- Godot 4.4+ resource UIDs (`*.uid` sidecar files, `uid://...` references) are auto-generated — never hand-write a `uid://` value; let the editor create it on first save/import.

## Working style

- Ask before making non-trivial gameplay/architecture decisions rather than assuming — this project has several intentionally open design questions (see docs/design/) and the user wants to weigh in on them directly.
- When a decision gets made in conversation, update the relevant `docs/design/*.md` file (move it out of "Open Questions" into the resolved section) rather than leaving it only in chat history.

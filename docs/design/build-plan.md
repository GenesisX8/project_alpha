# Game Build Plan — Project Alpha

> Migrated from `documents/Game Build.docx`, with two updates from planning discussions: (1) combat is confirmed **stationary** (no spatial grid), so "board" below means *battle state*, not a spatial board; (2) the GDScript/C# split flagged as an open question in the original is now resolved — see below.

## Overview — Build Order

1. **Rules document** — write the actual game rules in plain text before any code exists. *(Largely resolved — see [rules.md](rules.md). Remaining gaps are tuning numbers, not mechanics.)*
2. **Card data model** — define a Card Resource and get a handful of real cards represented as data, not code. *(Done — `scripts/card.gd`, `cards/card_fireball.tres`, `cards/card_frostbolt.tres`.)*
3. **Game state & turn structure** — a state machine for turn phases, independent of any rendering.
4. **Zones & battle-state model** — deck, hand, discard, active-effects, party/enemy status as data containers with clear transition rules.
5. **Effect/ability system** — the hardest part of any TCG-adjacent system: an event-driven system for triggered/activated abilities.
6. **Minimal functional UI** — plain buttons/labels wired to the state machine, used to validate rules end-to-end.
7. **Networking (only if multiplayer)** — not currently planned; single-player only for now.
8. **Content pipeline** — a card editor or data-import workflow so you're not hand-authoring `.tres` Resources forever.
9. **Real UI/UX and juice** — art (pixel art), animations, audio — last, once mechanics are locked.
10. **AI opponent** — built against the same state machine as the UI, not against the UI itself.

Everything below expands on why each step matters and Godot-specific notes for this project (Godot 4.7.1, standard build, **GDScript as the only language**).

## 1. Rules document

Before touching more Godot code: turn structure, win/loss conditions, resource system (card cost, if any resource beyond hand size), card types, zone transitions, and any "priority"/interrupt rules for cards. Interaction rules are where these systems live or die — what happens when a trap card and a triggered ability overlap, etc. If this is fuzzy, everything built on top of it needs rework later. See [rules.md](rules.md) for current state and open questions — several turn-structure questions (turn order mechanic, card-vs-action interaction) are still open and are the highest-leverage thing to resolve next.

## 2. Card data model

Using a custom `Resource` (not a scene) for card definitions — already in place:

```gdscript
extends Resource
class_name Card

@export var id: int
@export var name: String
@export var description: String
@export var cost: int
@export var damage: int
@export var health: int
@export var effects: Array[String]
@export var effect_duration: int
@export var rarity: String
```

Resources are serializable, editable in the Inspector, and easy to save as `.tres` files — this is the card database. Still open: are effects described by **data** (a small DSL/enum of effect types the engine interprets — the `effects: Array[String]` tags like `"burn"` hint at this direction already) or by **code** (each card is its own script)? Data-driven is more work up front but scales far better past a couple dozen cards; code-per-card is faster initially but becomes unmaintainable quickly. Most shipped digital TCGs (Hearthstone, Slay the Spire) lean data-driven with a library of composable effect primitives — worth defaulting to that unless there's a strong reason not to.

## 3. Game state & turn structure

A `GameController` (`scripts/game_controller.gd` already exists as a stub) or a dedicated `GameState` autoload/singleton should own a state machine for turn phases — something like `Draw → Action Selection → Resolution → End`, once the turn-order mechanic (see [rules.md](rules.md)) is decided. Since combat is stationary, there's no movement/positioning phase to model — this is simpler than a grid-tactics state machine would be.

This state machine should be **completely UI-agnostic** — it should work driven from unit tests, a headless script, or a real UI. That separation is what lets the rules be tested without touching a single button node. This is the same principle Godot's own docs recommend for separating game logic from presentation.

## 4. Zones & battle-state model

Model each card zone (deck, hand, discard, active-effects) as a plain data container — an `Array[Card]` or a small wrapper class — with explicit `move_card(card, from_zone, to_zone)` operations that enforce legality. Route zone mutations through the game state rather than letting UI code touch the arrays directly, so the UI is a view of state, not a source of truth. `PlayerDeck` (`scripts/player_deck.gd`) already has the beginnings of this (`cards`, `hand`) but `play_card()` currently just removes a card from hand without routing it anywhere (e.g. to a discard pile) — worth fixing once the discard zone is decided on.

Party/enemy battle status (HP, active buffs/traps, defend state) is separate from card zones but follows the same principle: one authoritative state object per combatant, read by the UI, never mutated directly by it.

## 5. Effect/ability system (and the interrupt stack)

Recommended approach: an event bus (Signal-based in Godot) that broadcasts game events (`card_played`, `character_defeated`, `turn_started`, etc.), and effects/abilities subscribe to the events they care about. Keep effects as small composable actions (`deal_damage`, `apply_buff`, `draw_card`) rather than one large per-card branch — this is what lets new cards get added later by combining existing primitives instead of writing bespoke logic each time. In Godot, this is typically an autoload singleton exposing the relevant signals.

**Interrupt stack scope note**: [rules.md](rules.md) commits to a full MTG-style priority/interrupt stack (actions can be responded to before they resolve, potentially in a chain). This is a genuinely hard system — it's the reason most solo/small-team TCG-likes scope it down. A suggested incremental path so step 6's "minimal functional UI" milestone is reachable without building the whole stack up front:

1. Start with **immediate resolution** (every card/action resolves instantly, no responses) to get the event bus and effect primitives working at all.
2. Add **conditional triggers** next (a trap can be set and fire later off an event, e.g. "when an enemy attacks this character") — still no interrupting an in-progress resolution, just deferred resolution.
3. Only then add the actual **stack/priority window** (pause after an action is declared, before it resolves, to let reactive cards respond — potentially recursively). This is the step that needs the most careful design (what can respond to what, how deep can chains go, how ties in speed/priority are broken).

Treat 1 → 2 → 3 as milestones, not a single task — trying to build the full stack before anything resolves at all will stall the project the way the Build Plan's own philosophy warns against.

## 6. Minimal functional UI

Wire up plain buttons/labels that call into the game state machine. The goal is to play a full battle against yourself with zero art. This validates the rules and surfaces design problems (an unreachable action, a card that soft-locks the game) while they're still cheap to fix. This is the current prototyping focus — no save/load system until this works end-to-end.

## 7. Networking

Not planned — this project is single-player only. Skip.

## 8. Content pipeline

Hand-editing dozens of `.tres` Resource files in the Inspector doesn't scale. Consider a simple custom editor (Godot plugin/dock) or importing card data from a spreadsheet/JSON into Resources via an `@tool` script. Do this once there are enough cards that manual editing is genuinely annoying — not before.

## 9. Real UI/UX and polish

Once mechanics are proven: pixel art assets (replacing the current placeholder `chibi_player.svg`), animations for attacks/effects, sound/juice. Cheapest to do last, against locked rules — and the most tempting to start with first, which is exactly why it's ordered last here.

## 10. AI opponent

Write enemy AI against the `GameState` API from step 3 — the same interface the UI uses. A simple heuristic/greedy evaluator (score a few candidate actions, pick the best) is usually enough for a first pass; don't reach for anything fancier until basic rules-following AI exists.

## What's easy to miss

- **Randomness/determinism** — decide early if shuffles/draws need to be seeded/replayable (useful for debugging and reproducing bug reports).
- **Undo/replay logging** — if state mutations are centralized (steps 3/4), logging every action for replay/debugging is nearly free; bolting it on later is not.
- **Mulligan/redraw rules and empty-deck behavior** — flagged as open questions in [rules.md](rules.md); commonly forgotten edge cases.
- **GDScript vs. C# split — resolved, and no longer a split.** .NET/C# was removed from the project; it runs on the standard Godot build, so **GDScript is the only option.** There is no `.csproj` and `config/features` does not include `"C#"` (see [CLAUDE.md](../../CLAUDE.md)).
- **Testing the rules engine in isolation** — since it's UI-agnostic, GUT (Godot Unit Test) or plain script-based tests can simulate full battles without ever opening a scene. Worth setting up once step 3 exists, since these interaction rules are exactly the kind of thing that silently breaks when card #47 gets added.

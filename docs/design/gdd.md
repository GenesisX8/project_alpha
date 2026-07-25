# Game Design Document — Project Alpha

> Migrated from `documents/Game Design.docx` (a generic GDD template that was never filled in) and updated with decisions made in planning discussions. This is the canonical design reference — see also [rules.md](rules.md) for detailed combat rules and [build-plan.md](build-plan.md) for implementation order.

## Overview

| | |
|---|---|
| **Working title** | Project Alpha |
| **Genre** | Tactical Turn-Based RPG (party-based, stationary combat) with an additive card-based ability system |
| **Players** | Single-player |
| **Platform (v1)** | PC desktop — Windows, Mac, Linux |
| **Engine** | Godot 4.7.1 (Mono/.NET build) |
| **Primary language** | GDScript (C# enabled in-project but not actively used) |
| **Visual style** | 2D pixel art |

## Pitch

A party-based, turn-based RPG in the classic mold (think Final Fantasy / Dragon Quest-era battles: stationary party lined up against a group of enemies, no spatial movement grid). On top of the standard Attack/Skill/Item/Defend action set, characters can also play cards — a hand of spells, buffs, and traps drawn from a deck — adding a light deck-building layer to otherwise traditional JRPG combat.

## Core gameplay loop

1. Party (multiple player-controlled characters) enters battle against a group of enemies.
2. Combat is **not** grid-based — combatants are stationary; there's no movement/positioning sub-system to design or implement.
3. On each character's turn, the player chooses an action:
   - **Attack** — standard physical attack
   - **Skill** — fixed per-character/per-class ability (character's innate skill list)
   - **Item** — consumable
   - **Defend** — reduce incoming damage this round
   - **Play Card** — spend a card from hand for an additional spell/buff/trap effect
4. Battle resolves when one side is defeated (exact win/loss conditions: see [rules.md](rules.md)).

This is deliberately close to traditional JRPG structure — the card system is a supplementary layer of variety and strategic depth, not a replacement for the core combat identity.

## Card system

Cards represent spells, buffs, and traps that supplement a character's fixed skill list, plus resource cards that feed each character's mana/rage/etc. pool. The `Card` resource (`scripts/card.gd`) already models: `id`, `name`, `description`, `cost`, `damage`, `health`, `effects` (array of tags, e.g. `"burn"`), `effect_duration`, `rarity`.

**Resolved** (full detail in [rules.md](rules.md)):
- Cards are drawn from **one shared party deck/hand** (not per-character) into a hand, and played via a dedicated "Play Card" action that can combine with a standard action rather than replacing it.
- The deck includes both effect cards (spells/buffs/traps) and **resource cards** — playing a resource card fills a chosen character's own resource pool (each character has their own resource type, e.g. Mana vs. Rage).
- **Deckbuilding is a real meta-layer**: the player builds their own deck (choosing which effect and resource cards go into it), it's not a fixed/preset loadout.
- Card interactions use a **full priority/interrupt stack** (MTG-style) — a deliberate, high-scope choice; see [build-plan.md](build-plan.md#effect-ability-system-and-the-interrupt-stack) for a suggested incremental build path.

**Open questions:**
- Where do new cards come from during a run (starting collection, rewards after battle, shop/economy, random drops) — the deckbuilding *moment* (build once vs. between every battle) isn't defined yet either.
- `PlayerDeck`'s current implementation (`scripts/player_deck.gd`) is attached per-`CharacterBody2D` (see `Prototype2D.tscn`) — this needs to move to a party-level shared owner (e.g. a `PartyDeck` autoload/singleton or a node owned by a party controller) now that the shared-deck model is confirmed.

## Party & characters

**Open questions:**
- How many characters in the active party (e.g., 3? 4? 5?) and is there a separate bench/reserve?
- Character roster — classes/archetypes, how many at launch, stat spread.
- Enemy composition — typical enemy group size, whether enemies also use cards or just fixed skill lists.

## Technical specs

- **Engine**: Godot 4.7.1, Mono/.NET build.
- **Rendering**: Forward+.
- **Target platform**: PC desktop (Windows/Mac/Linux) for v1. Mobile/console explicitly out of scope for now (the original template's iOS/Android/console list was aspirational, not a v1 commitment).
- **Visual style**: 2D pixel art. Current placeholder art (`sprites/chibi_player.svg`) is a vector chibi-style asset and will be replaced — it does not represent final direction.
- **Save/persistence**: out of scope for the current prototyping phase. Focus is proving out one full battle end-to-end first (see [build-plan.md](build-plan.md)).

## Open questions (design-level, cross-cutting)

- Progression/meta systems (leveling, equipment, currency) — not yet discussed at all.
- Narrative/setting — genre and mechanics are defined; no story, world, or tone decisions have been made yet.
- Art pipeline — who's producing pixel art assets, target resolution/tile size, reference style.

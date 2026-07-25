# Gameplay Rules — Project Alpha

> Migrated from `documents/Rules.docx`. That draft's turn sequence (Draw / Resource Field / Field / Move / Attack / Final) assumed spatial movement on a board — combat is confirmed **stationary** (no grid/movement), so that sequence was re-derived rather than copied as-is. See [gdd.md](gdd.md) for the overall concept and [build-plan.md](build-plan.md) for implementation order.

## Battle start

- **Who acts first**: decided randomly (coin flip / dice roll) at the start of each battle. No player choice, no fixed attacker/defender role.
- **Opening hand**: each side draws a fixed hand size at battle start. No mulligan/redraw.
  - *Open question*: the exact hand size number is a tuning value, not yet set.

## Turn order

Turn order is **Speed/Agility-stat-based and dynamic** — recomputed each round from combatants' Speed stats, classic Final Fantasy-style. Faster combatants act sooner, and can act more often than slower ones over a long battle (rather than a fixed party-then-enemies alternation).

## Turn structure

On their turn, a character may take a **standard action** (Attack / Skill / Item / Defend) **and** optionally **play a card** — cards can combine with a standard action rather than consuming the whole turn. Exact limits (e.g. one card per turn vs. multiple, provided resources allow it) are not yet set.

- **Attack** — standard physical attack against a target.
- **Skill** — a fixed ability from that character's own skill list.
- **Item** — use a consumable.
- **Defend** — reduce incoming damage until this character's next turn.
- **Play Card** — spend a card from the shared party hand (see [Card system](#card-system) below) for its effect, in the same turn as a standard action.

## Card system

- **Deck ownership**: one **shared deck/hand for the whole party** (not per-character). Any character can play a card from the shared hand on their turn.
- **Deckbuilding**: the player builds their own deck before battle, choosing which cards (including which resource cards — see below) go into it. This is a real meta-layer, not a fixed/preset deck.
- **Card timing / interrupts**: cards use a **full priority/interrupt stack** (MTG-style) — a played card or ability can be responded to before it resolves, potentially in a chain. This is a deliberate, significant scope commitment for a 2-person team; see the callout in [build-plan.md](build-plan.md#effect-ability-system-and-the-interrupt-stack) for a suggested incremental build path (don't build the full stack on day one).
- **Empty deck**: once the deck is empty, the character/party simply stops drawing — no penalty, no "fatigue" damage.
  - *Open question (inferred, not explicitly confirmed)*: whether the discard pile ever reshuffles back into the deck, or stays discarded for the rest of the battle. Current assumption is **no auto-reshuffle** — flag if that's wrong.

## Resource system (mana/energy)

A **hybrid, per-character resource model**:

- Each character has their **own resource type** (e.g. a Mage's Mana, a Warrior's Rage) and their own pool/balance of it — resources are not a single shared party-wide currency.
- The player's deck can include **resource cards** of multiple types (mana cards, rage cards, etc.) alongside spell/buff/trap cards, mixed into the same shared deck/hand described above.
- Playing a resource card lets the player add its value to **any specific character's** resource pool, not just the pool of whoever's turn it is — i.e. resource allocation is a flexible choice the player makes each time a resource card is played, not automatically tied to the current turn's actor.
- A `Card`'s `cost` (see `scripts/card.gd`) is paid from the relevant character's own resource pool, in the resource type that ability requires.

*Open questions*: exact numbers (starting pool sizes, resource card values, whether pools carry over between turns/battles or reset), and whether a character can spend from another character's pool or only their own (only pool *filling* via resource cards has been specified as flexible — spending has not).

## Win / loss conditions

- **Win**: all enemies reduced to 0 HP / defeated.
- **Loss**: the **entire party downed simultaneously** (see below — individual downs don't end the battle since units are revivable).
- No escape/flee option, turn-limit battles, or objective-based battles for now — standard win/loss only.

## Downed characters

A party member reduced to 0 HP is **downed, not removed from the battle** — they can be revived mid-battle via an item/skill/card. This requires the character's state to distinguish "downed" (temporarily out, revivable) from "removed" (not currently used, since there's no permanent-removal case defined). The battle only ends in a loss when the whole party is downed at the same time.

## Card zones

- **Deck** — the draw pile (per the shared-deck model above).
- **Hand** — shared party hand, drawn from the shared deck.
- **Discard** — cards already played (not yet modeled in code — `player_deck.gd`'s `play_card()` currently removes from hand but doesn't route the card anywhere; needs a discard zone once this is implemented).
- **Active/in-play** — for buffs/traps with a duration (`Card.effect_duration`), and for the interrupt-stack's pending/reactive cards (traps waiting on a trigger condition).

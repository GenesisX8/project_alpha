class_name PlayerDeck extends Node

@export var card_db: CardDatabase
var cards: Array[Card] = []
var hand: Array[Card] = []
var max_hand_size: int = 5

signal deck_loaded

func _ready():
	pass

# Add your cards to the deck
func load_deck():
	for card in card_db.cards:
		cards.append(card.duplicate())
	deck_loaded.emit() # Signal when deck is loaded
	print("Deck loaded successfully with ", cards.size(), " cards")

func draw_card() -> Card:
	# TODO(design): empty-deck behaviour is an open question — reshuffle the
	# discard pile back in, or fatigue/no-draw? See docs/design/rules.md.
	if cards.is_empty():
		print("No cards in your deck!")
		return null

	# TODO(design): max_hand_size is declared but not enforced here, because
	# "what happens when you draw on a full hand" (discard, or skip the draw)
	# is not decided yet. See docs/design/rules.md.

	# NOTE: drawing a uniformly random index and removing it is equivalent to
	# drawing off a pre-shuffled deck, so this does not pre-empt the shuffle
	# design. TODO(design): randi() is unseeded — the build plan flags
	# determinism/replayability as a decision to make early.
	var index := randi() % cards.size()
	var card: Card = cards[index]
	cards.remove_at(index)
	hand.append(card)
	print("Drew: ", card.name)
	return card

func add_card(card: Card):
	cards.append(card)

func get_card_by_id(id: int) -> Card:
	for card in cards:
		if card.id == id:
			return card
	return null

func play_card(card: Card):
	if card in hand:
		hand.erase(card)
		print("Played: ", card.name)
	else:
		print("Card not in hand!")
	return null

func get_hand() -> Array[Card]:
	return hand

func print_deck():
	print("=== PLAYER DECK ===")
	print("Total cards: ", cards.size())

	for i in range(cards.size()):
		var card: Card = cards[i]
		if !card:
			print("[%d] NULL CARD" % i)
		else:
			print("[%d] %s - Cost: %d | Damage: %d | Effects: %s | Effect Duration: %d" % [
				i,
				card.name,
				card.cost,
				card.damage,
				", ".join(card.effects),
				card.effect_duration,
			])

	print("=== END DECK ===")

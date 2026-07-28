extends Node

@onready var deck: PlayerDeck = $Deck
@onready var party: Party = $Party

@export var debug_deck: bool = false
@export var debug_hand: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the player's party
	# print("About to load party...")
	await get_tree().process_frame

	# Load the player's deck
	# print("About to load deck...")
	await get_tree().process_frame

	# Print the deck if debug_deck is enabled
	if debug_deck:
		deck.print_deck()

	# Print the hand if debug_hand is enabled
	if debug_hand:
		deck.print_hand()
	# print("Done calling load_deck()")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

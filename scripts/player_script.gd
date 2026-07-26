extends Node

@onready var deck: PlayerDeck = $Deck
@onready var party: Party = $Party

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the player's party
	print("About to load party...")
	await get_tree().process_frame
	print("Calling load_party() now...")
	load_party()
	print("Done calling load_party()")
	# Finished loading party

	# Load the player's deck
	print("About to load deck...")
	await get_tree().process_frame
	print("Calling load_deck() now...")
	# Call directly since signal may have already been emitted
	load_deck()
	print("Done calling load_deck()")
	# Finished loading deck


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Load the player's deck
func load_deck() -> void:
	deck.print_deck()
	pass

# Load the player's party
func load_party() -> void:
	party.print_party()
	pass

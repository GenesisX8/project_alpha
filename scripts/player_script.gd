extends CharacterBody2D

@onready var deck: PlayerDeck = $Deck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("About to print deck...")
	await get_tree().process_frame
	print("Calling print_deck() now...")
	# Call directly since signal may have already been emitted
	deck.print_deck()
	print("Done calling print_deck()")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

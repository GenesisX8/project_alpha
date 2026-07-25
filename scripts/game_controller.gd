extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load cards when the game starts
	var fireball = load("res://cards/card_fireball.tres")
	print(fireball.name, " costs ", fireball.cost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func use_card(card: Card):
	print("Using card: ", card.name)

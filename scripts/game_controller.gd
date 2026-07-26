extends Node
class_name GameController


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load_player_assets()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## TODO: 1. Start of combat
func start_combat() -> void:
	## Initialize the combat state and Load assets
	## Load player assets
	# load_player_assets()

	## Load enemy assets

	## Set up the initial combat environment
	
	## Initialize player and enemy stats
	
	## Deal starting hands

	## Determine turn order

	pass

## TODO: 2. Player's turn
func player_turn() -> void:
	pass

## TODO: 3. enemy's turn
func enemy_turn() -> void:
	pass

## TODO: 4. End of combat
func end_combat() -> void:
	pass

func load_player_assets() -> void:
	pass
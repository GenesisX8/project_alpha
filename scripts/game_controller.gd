class_name GameController extends Node

@export var prototype2d: Node2D
@export var debug_enemies: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load_player_assets()
	start_combat()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## TODO: 1. Start of combat
func start_combat() -> void:
	## Initialize the combat state and Load assets
	## Load player assets
	# load_player_assets()

	## Load enemy assets at combat start
	# print("Loading enemy assets...")
	prototype2d.load_enemies()

	# Print enemies if debug_enemies is enabled
	if debug_enemies:
		prototype2d.print_enemies()	
	
	# print("Enemy assets loaded.")

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

# Load player assets
func load_player_assets() -> void:
	pass

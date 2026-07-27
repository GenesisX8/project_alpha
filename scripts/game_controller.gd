class_name GameController extends Node

@export var enemies: Array[Enemy] = []
var number_of_enemies: int = 1

signal enemies_loaded(enemies: Array[Enemy])

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
	print("Loading enemy assets...")
	load_enemies()
	print_enemies()
	print("Enemy assets loaded.")

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

# Load enemy assets
func load_enemies() -> void:
	enemies.append(load("res://enemies/e_scorpion.tres").duplicate())
	enemies.append(load("res://enemies/e_wolf.tres").duplicate())
	enemies.append(load("res://enemies/e_wraith.tres").duplicate())
	enemies_loaded.emit(enemies)
	print("Enemies loaded successfully with ", enemies.size(), " enemies")

func print_enemies() -> void:
	print("=== Enemies: ===")

	for i in range(enemies.size()):
		var p_enemy = enemies[i]
		if p_enemy == null:
			print("[%d] NULL ENEMY" % i)
		else:
			print("[%d] %s - Health: %d | Attack: %d | Defense: %d | Skills: %s" % [
				i,
				p_enemy.name,
				p_enemy.health,
				p_enemy.attack,
				p_enemy.defense,
				", ".join(p_enemy.skills),
			])

	print("=== End of enemies ===")

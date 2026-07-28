class_name GameController extends Node

@export var prototype2d: Node2D
@export var enemies: Array[Enemy]
@export var party: Party
@export var heroes: Array[Hero]
@export var player_deck: PlayerDeck
@export var deck: Array[Card]
@export var hero1: Hero
@export var hero2: Hero
@export var hero3: Hero
@export var enemy1: Enemy
@export var enemy2: Enemy
@export var enemy3: Enemy
@export var debug_party: bool = false
@export var debug_enemies: bool = false
@export var debug_turn_order: bool = false

@export var first_attacker: bool = false # false for "player", true for "enemy"
var player_input: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_combat() # Load assets at start of combat
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## TODO: 1. Start of combat
func start_combat() -> void:
	## Initialize the combat state and Load assets
	heroes = party.load_party() # Load player party assets
	hero1 = heroes[0] if heroes.size() > 0 else null
	hero2 = heroes[1] if heroes.size() > 1 else null
	hero3 = heroes[2] if heroes.size() > 2 else null

	# Print party if debug_party is enabled
	if debug_party:
		party.print_party()

	## Load enemy assets at combat start
	enemies = prototype2d.load_enemies() # Load enemy assets
	enemy1 = enemies[0] if enemies.size() > 0 else null
	enemy2 = enemies[1] if enemies.size() > 1 else null
	enemy3 = enemies[2] if enemies.size() > 2 else null

	# Print enemies if debug_enemies is enabled
	if debug_enemies:
		prototype2d.print_enemies()	
	
	# Load player deck
	deck = player_deck.load_deck()

	## Set up the initial combat environment
	## Determine who attacks first
	var combatants = turn_order(heroes, enemies)

	if debug_turn_order:
		print("Turn order:")	
		for combatant in combatants:
			print(combatant.name)

	if combatants[0].label == "Hero":
		## Player attacks first
		player_turn()
		print(combatants[0].name + " attacks first!")
		pass
	else:
		## Enemy attacks first
		enemy_turn()
		print(combatants[0].name + " attacks first!")
		pass

	## Initialize player and enemy stats
	
	## Deal starting hands


## TODO: 2. Player's turn
func player_turn() -> void:
	listen_for_input()
	return



## TODO: 3. enemy's turn
func enemy_turn() -> void:
	pass

## TODO: 4. End of combat
func end_combat() -> void:
	pass

# Load player assets
func load_player_assets() -> void:
	pass

# Determine turn order
func turn_order(_heroes: Array, _enemies: Array) -> Array:
	# Logic to determine turn order based on agility or other factors
	var combatants = [] # List of all combatants (heroes and enemies)
	combatants.append_array(heroes)
	combatants.append_array(enemies)
	# Sort combatants by agility (or other criteria)
	combatants.shuffle()
	combatants.sort_custom(func(a, b): return a.agility > b.agility)
	return combatants


func _input(event: InputEvent) -> void:
	if not player_input:
		return
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_1:
			select_option(1) # Handle key 1 press
		KEY_2:
			select_option(2) # Handle key 2 press
		KEY_3:
			select_option(3) # Handle key 3 press
		
func select_option(index: int) -> void:
	print("Selected option: ", index)
	player_input = false # stop listening after selection is made
	# Attack logic would go here

func listen_for_input() -> void:
	player_input = true
	print("Choose an action: 1=Attack, 2=Defend, 3=Skill")

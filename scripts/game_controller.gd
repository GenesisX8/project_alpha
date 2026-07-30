class_name GameController extends Node

enum TurnState { ACTION_MENU, TARGET_SELECT }

const ACTION_LABELS: Array[String] = ["Attack", "Defend", "Skill"]

@export var player_deck: PlayerDeck
@export var deck: Array[Card]

@export var party: Party
@export var heroes: Array[Hero]

@export var prototype2d: Node2D
@export var enemies: Array[Enemy]

@export var hero1: Hero
@export var hero2: Hero
@export var hero3: Hero

@export var enemy1: Enemy
@export var enemy2: Enemy
@export var enemy3: Enemy

@export var debug_party: bool = false
@export var debug_enemies: bool = false
@export var debug_turn_order: bool = false

@export var combat_menu: Control
@export var attack_button: Button
@export var defend_button: Button
@export var skill_button: Button

@export var target_menu: Control
@export var target1_button: Button
@export var target2_button: Button
@export var target3_button: Button

@export var combat_text_box: RichTextLabel
@onready var combat_text: String

var player_input: bool = false

var _turn_state: TurnState = TurnState.ACTION_MENU
var _cursor_index: int = 0
var _pending_action: String = ""
var _current_hero: Hero

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
	combat_text = "Party loaded successfully! " + heroes[0].name + ", " + heroes[1].name + ", " + heroes[2].name
	combat_text_box.append_text(combat_text)
	hero1 = heroes[0] if heroes.size() > 0 else null
	hero2 = heroes[1] if heroes.size() > 1 else null
	hero3 = heroes[2] if heroes.size() > 2 else null
	print("CombatText: " + combat_text)

	# Print party if debug_party is enabled
	if debug_party:
		party.print_party()

	## Load enemy assets at combat start
	enemies = prototype2d.load_enemies() # Load enemy assets
	enemy1 = enemies[0] if enemies.size() > 0 else null
	enemy2 = enemies[1] if enemies.size() > 1 else null
	enemy3 = enemies[2] if enemies.size() > 2 else null
	combat_text = "Enemies loaded successfully! " + enemy1.name + ", " + enemy2.name + ", " + enemy3.name
	combat_text_box.append_text(combat_text)

	target1_button.text = enemy1.name
	target2_button.text = enemy2.name
	target3_button.text = enemy3.name

	# Print enemies if debug_enemies is enabled
	if debug_enemies:
		prototype2d.print_enemies()	
	
	# Load player deck
	deck = player_deck.load_deck()

	## Set up the initial combat environment
	## Determine who attacks first
	call_turn()

	## Initialize player and enemy stats
	
	## Deal starting hands


## TODO: 2. Player's turn
func player_turn(hero: Hero) -> void:
	attack_button.grab_focus()
	listen_for_input(hero)
	return

## TODO: 3. enemy's turn
func enemy_turn(_enemy: Enemy) -> void:
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

	if debug_turn_order:
		print("Turn order:")	
		for combatant in combatants:
			print(combatant.name)

	return combatants

func call_turn() -> void:
	# Logic to call the appropriate turn function
	var combatants = turn_order(heroes, enemies)

	if combatants[0].label == "Hero":
		## Player attacks first
		player_turn(combatants[0])
		print(combatants[0].name + " strikes first!")
	else:
		## Enemy attacks first
		enemy_turn(combatants[0])
		print(combatants[0].name + " strkes first!")

func listen_for_input(hero: Hero) -> void:
	_current_hero = hero
	_turn_state = TurnState.ACTION_MENU
	_cursor_index = 0
	_pending_action = ""
	player_input = true

func _get_current_options() -> Array:
	match _turn_state:
		TurnState.ACTION_MENU:
			return ACTION_LABELS
		TurnState.TARGET_SELECT:
			return _get_valid_targets()
	return []

func _get_valid_targets() -> Array[Enemy]:
	var targets: Array[Enemy] = []
	for e in enemies:
		if e != null:
			targets.append(e)
	return targets

# _pending_action = ACTION_LABELS[_cursor_index]
func _confirm_action() -> void:
	match _pending_action:
		"Attack", "Skill":
			_turn_state = TurnState.TARGET_SELECT
			target1_button.grab_focus()
			_cursor_index = 0
		"Defend":
			combat_text = "%s defends!" % _current_hero.name
			combat_text_box.text = combat_text
			print("%s defends!" % _current_hero.name)
			_end_player_turn()

func _confirm_target(target_index: int) -> void:
	var targets := _get_valid_targets()
	var target: Enemy = targets[target_index]
	match _pending_action:
		"Attack":
			_current_hero.fattack(target)
		"Skill":
			# TODO: no skill-effect system yet (see docs/design/build-plan.md#5); stub only.
			print("%s attempts a skill on %s (not implemented yet)." % [_current_hero.name, target.name])
	combat_text = _current_hero.combat_text
	combat_text_box.text = combat_text
	_end_player_turn()

func _cancel_target_selection() -> void:
	_turn_state = TurnState.ACTION_MENU
	_cursor_index = 0
	_pending_action = ""

func _end_player_turn() -> void:
	player_input = false
	_pending_action = ""

# TODO: DEPRECATED REMOVE OLD CONSOLE MENU!
# Print the current menu
func _print_menu() -> void:
	match _turn_state:
		TurnState.ACTION_MENU:
			print("-- %s's turn -- (Up/Down to move, Enter to select)" % _current_hero.name)
			for i in ACTION_LABELS.size():
				print(("> " if i == _cursor_index else "  ") + ACTION_LABELS[i])
		TurnState.TARGET_SELECT:
			print("Choose a target: (Up/Down to move, Enter to select, Esc to go back)")
			var targets := _get_valid_targets()
			for i in targets.size():
				print(("> " if i == _cursor_index else "  ") + targets[i].name)


func _on_attack_button_pressed() -> void:
	if _turn_state == TurnState.ACTION_MENU:
		combat_text = "%s chooses to attack!" % _current_hero.name
		combat_text_box.text = combat_text
		print("%s chooses to attack!" % _current_hero.name)
		_pending_action = "Attack"
		_confirm_action()

func _on_defend_button_pressed() -> void:
	if _turn_state == TurnState.ACTION_MENU:
		combat_text = "%s chooses to defend!" % _current_hero.name
		combat_text_box.text = combat_text
		print("%s chooses to defend!" % _current_hero.name)
		_pending_action = "Defend"
		_confirm_action()

func _on_skill_button_pressed() -> void:
	if _turn_state == TurnState.ACTION_MENU:
		combat_text = "%s chooses to use a skill!" % _current_hero.name
		combat_text_box.text = combat_text
		print("%s chooses to use a skill!" % _current_hero.name)
		_pending_action = "Skill"
		_confirm_action()

func _on_target_1_button_pressed() -> void:
	if _turn_state == TurnState.TARGET_SELECT:
		_confirm_target(0) # 0 refers to the first target in the list

func _on_target_2_button_pressed() -> void:
	if _turn_state == TurnState.TARGET_SELECT:
		_confirm_target(1) # 1 refers to the second target in the list

func _on_target_3_button_pressed() -> void:
	if _turn_state == TurnState.TARGET_SELECT:
		_confirm_target(2) # 2 refers to the third target in the list

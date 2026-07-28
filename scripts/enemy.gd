class_name Enemy extends Resource

@export var id: int
@export var label: String
@export var level: int
@export var name: String
@export var description: String
@export var type: String
@export var max_health: int
@export var current_health: int
@export var attack: int
@export var defense: int
@export var agility: int
@export var skills: Array[String]
@export var isdead: bool = false

func check_death() -> bool:
	if current_health <= 0:
		isdead = true
		return true
	return false

func fattack(target: Hero) -> int:
	# Logic for the enemy's attack
	var damage = attack
	target.current_health -= damage
	print("%s attacks %s for %d damage" % [name, target.name, damage])
	return damage

func _init(
	p_id: int = 0,
	p_label: String = "",
	p_level: int = 1,
	p_name: String = "",
	p_description: String = "",
	p_type: String = "",
	p_max_health: int = 0,
	p_current_health: int = 0,
	p_attack: int = 0,
	p_defense: int = 0,
	p_agility: int = 0,
	p_skills: Array[String] = [],
):
	id = p_id
	label = p_label
	level = p_level
	name = p_name
	description = p_description
	type = p_type
	max_health = p_max_health
	current_health = p_current_health
	attack = p_attack
	defense = p_defense
	agility = p_agility
	skills = p_skills
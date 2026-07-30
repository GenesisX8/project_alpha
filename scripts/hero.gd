class_name Hero extends Resource

@export var id: int
@export var label: String
@export var level: int
@export var name: String
@export var description: String
@export var max_health: int
@export var current_health: int
@export var attack: int
@export var defense: int
@export var agility: int
@export var skills: Array[String]
@export var isdead: bool = false
var combat_text: String

func check_death() -> bool:
	if current_health <= 0:
		isdead = true
		return true
	return false

func fattack(target: Enemy) -> int:
	# Logic for hero's attack
	var damage = attack
	var combat_text1 = "%s attacks %s for %d damage " % [name, target.name, damage]
	var combat_text2: String
	target.current_health -= damage
	print("%s attacks %s for %d damage" % [name, target.name, damage])

	if target.check_death():
		combat_text2 = "%s has been defeated!" % target.name
		print("%s has been defeated!" % target.name)
		target.current_health = 0
	else:
		combat_text2 = "%s is still standing!" % target.name
		print("%s is still standing!" % target.name)

	combat_text = combat_text1 + combat_text2 + " %s has %d health remaining" % [target.name, target.current_health]
	print("%s has %d health remaining" % [target.name, target.current_health])
	return damage

func _init(
	p_id: int = 0,
	p_label: String = "",
	p_level: int = 1,
	p_name: String = "",
	p_description: String = "",
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
	max_health = p_max_health
	current_health = p_current_health
	attack = p_attack
	defense = p_defense
	agility = p_agility
	skills = p_skills

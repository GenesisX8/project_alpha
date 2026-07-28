class_name Enemy extends Resource

@export var id: int
@export var label: String
@export var level: int
@export var name: String
@export var description: String
@export var type: String
@export var health: int
@export var attack: int
@export var defense: int
@export var agility: int
@export var skills: Array[String]

func _init(
	p_id: int = 0,
    p_label: String = "",
    p_level: int = 1,
    p_name: String = "",
    p_description: String = "",
    p_type: String = "",
    p_health: int = 0,
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
    health = p_health
    attack = p_attack
    defense = p_defense
    agility = p_agility
    skills = p_skills
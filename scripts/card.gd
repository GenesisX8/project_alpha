class_name Card extends Resource

@export var id: int
@export var name: String
@export var description: String
@export var cost: int
@export var damage: int
#@export var texture: Texture2D
@export var health: int
@export var effects: Array[String]
@export var effect_duration: int
@export var rarity: String # "common", "uncommon", "rare", "epic", "legendary"

func _init(
	p_id = 0,
	p_name = "",
	p_description = "",
	p_cost = 0,
	p_damage = 0,
	p_health = 0,
	p_effects: Array[String] = [],
	p_effect_duration = 0,
	p_rarity = "common",
):
	id = p_id
	name = p_name
	description = p_description
	cost = p_cost
	damage = p_damage
	health = p_health
	effects = p_effects
	effect_duration = p_effect_duration
	#texture = p_texture
	rarity = p_rarity

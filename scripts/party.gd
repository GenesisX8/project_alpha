class_name Party extends Node

@export var heroes: Array[Hero] = []
var party_size: int = 1
signal hero_loaded

func _ready() -> void:
	# load heroes when player is created
	load_heroes()

func load_heroes() -> void:
	heroes.append(load("res://heroes/h_Ahku.tres"))
	hero_loaded.emit() # Signal that a hero has been loaded
	print("Party loaded successfully with ", heroes.size(), " heroes")

func print_party() -> void:
	print("=== Party members: ===")

	for i in range(heroes.size()):
		var p_hero = heroes[i]
		if p_hero == null:
			print("[%d] NULL HERO" % i)
		else:
			print("[%d] %s - Health: %d | Attack: %d | Defense: %d" % [
				i, 
				p_hero.name, 
				p_hero.health, 
				p_hero.attack, 
				p_hero.defense, 
				])

	print("=== End of party members ===")

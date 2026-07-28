extends Node

@export var enemy_db: EnemyDatabase
var enemies: Array[Enemy] = []
var max_enemies: int = 3

signal enemy_loaded(enemy: Enemy)
signal enemies_loaded(enemies: Array[Enemy])
signal enemies_ready()

func _ready() -> void:
	enemies_loaded.emit()
	enemies_ready.emit()

func _process(_delta: float) -> void:
	pass

func load_enemies() -> Array[Enemy]:
	for enemy in enemy_db.enemies:
		enemies.append(enemy.duplicate())
	enemy_loaded.emit() # Signal that a enemy has been loaded
	print("Enemies loaded successfully with ", enemies.size(), " enemies")
	return enemies

func print_enemies() -> void:
	print("=== ENEMIES: ===")

	for enemy in enemy_db.enemies:
		if !enemy:
			print("[%d] NULL ENEMY" % enemy)
		else:
			print("Enemy: [%d] %s - Health: %d | Attack: %d | Defense: %d" % [
				enemy.id, 
				enemy.name, 
				enemy.health, 
				enemy.attack, 
				enemy.defense
			])
		
	print("=== END OF ENEMIES ===")

extends Node2D

@export var target_node: Node
@export var enemy_scene: PackedScene  # Assign your Enemy.tscn here in the editor
@export var spawn_interval := 0.5      # seconds between spawns
@export var max_enemies := 1
#@export var spawn_positions := [Vector2.ZERO]  # List of positions to spawn enemies at

var spawn_timer := 0.0


func _process(delta):
	
	if self.get_child_count() < max_enemies:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = spawn_interval
			spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		push_error("Enemy scene not assigned!")
		return

	# Pick a random spawn position (or use a pattern)
	#var pos = spawn_positions[randi() % spawn_positions.size()]
	var pos = Vector2.ZERO
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.set_target(target_node)
	add_child(enemy_instance)
	enemy_instance.position = pos

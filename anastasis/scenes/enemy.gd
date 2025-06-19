extends CharacterBody2D
@export var speed := 100
@export var target_node: Node

func _physics_process(delta):
	if target_node:
		var direction = (target_node.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(dmg: int):
	print("%s took %d damage" % [self.to_string(), dmg])
	queue_free()

func set_target(target: Node):
	target_node = target

extends Area2D

@onready var tilemap := get_node("/root/Game/TileMapLayer") # terrible code for refactoring

var damage: int = 10
var lifetime: float = 0.2

func _ready() -> void:
	print("enabled hitbox")
	$CollisionShape2D.disabled = false
	# Connect to body_entered or area_entered if needed
	self.connect("body_entered", _on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	("deleted hitbox")
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		print("hitting enemy")
		body.take_damage(damage)  # Ensure enemy has this method
	if body is TileMapLayer:
		print("hitting terrain")

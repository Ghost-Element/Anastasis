extends Area2D

@onready var tilemap := get_node("/root/Game/TileMapLayer") # terrible code for refactoring
@onready var collider = $CollisionShape2D

@export var damage: int = 1
@export var lifetime: float = 0.4

#orientation is a vector pointing in a direction (e.g. Vector2.DOWN)
#position.x = distance from player center forward, position.y = distance from player center perpendicular (right=positive)
func init_hitbox(size:Vector2, orientation:Vector2, position:Vector2, lifetime:float = 0.4, dmg:int = 1):
	$CollisionShape2D.disabled = false
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size
	self.position = position.x*orientation + position.y*orientation.rotated(90)
	self.rotation = Vector2.DOWN.angle_to(orientation)
	self.damage = dmg
	self.lifetime = lifetime
	self.connect("body_entered", _on_body_entered)
	print("enabled hitbox")
	#transform = transform.translated(position).looking_at(orientation)
	
	# wait until finished initialisation (otherwise get_tree() returns null)
	call_deferred("post_init_hitbox")

func post_init_hitbox():
	await self.get_tree().create_timer(lifetime).timeout
	print("deleted hitbox")
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, self)  # Ensure enemy has this method
		if get_parent() and get_parent().has_method("interrupt_charge"):
			get_parent().interrupt_charge()
			queue_free()
		self.get_parent()
	if body is TileMapLayer:
		print("%s is hitting terrain", [self])

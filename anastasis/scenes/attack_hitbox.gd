extends Area2D

@onready var tilemap := get_node("/root/Game/TileMapLayer") # terrible code for refactoring
@onready var collider = $CollisionShape2D

@export var damage: int = 1
@export var lifetime: float = 0.2

#always call init_hitbox after initializing hitbox
func _ready() -> void:
	# Connect to body_entered or area_entered if needed
	self.connect("body_entered", _on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	("deleted hitbox")
	queue_free()

#orientation is a vector pointing in a direction (e.g. Vector2.DOWN)
#position.x = distance from player center forward, position.y = distance from player center perpendicular (right=positive)
func init_hitbox(size:Vector2, orientation:Vector2, position:Vector2):
	print("enabled hitbox")
	$CollisionShape2D.disabled = false
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size
	self.position = position.x*orientation + position.y*orientation.rotated(90)
	self.rotation = Vector2.DOWN.angle_to(orientation)
	#transform = transform.translated(position).looking_at(orientation)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage, self)  # Ensure enemy has this method
	if body is TileMapLayer:
		print("Player is hitting terrain")

extends Area2D

#@onready var tilemap := get_node("/root/Game/TileMapLayer") # terrible code for refactoring
@onready var collider = $CollisionShape2D

@export var damage: int = 1
@export var defaultLifetime: float = 0.2
var lifetime: float
var knockback: float


#orientation is a vector pointing in a direction (e.g. Vector2.DOWN)
#position.x = distance from player center forward, position.y = distance from player center perpendicular (right=positive)
func init_hitbox(size:Vector2, orientation:Vector2, position:Vector2, lifetime:float = -1, dmg:int = 1, knockback:float = 0):
	$CollisionShape2D.disabled = false
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size
	self.position = position.x*orientation + position.y*orientation.rotated(90)
	self.rotation = Vector2.DOWN.angle_to(orientation)
	
	self.damage = dmg
	self.lifetime = lifetime if lifetime > 0 else self.defaultLifetime
	self.knockback = knockback
	self.connect("body_entered", _on_body_entered)
	print("enabled hitbox")
	
	# wait until finished initialisation (otherwise get_tree() returns null)
	call_deferred("post_init_hitbox")

func post_init_hitbox():
	print(self.lifetime)
	await self.get_tree().create_timer(self.lifetime).timeout
	print("deleted hitbox")
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(self)  # Ensure enemy has this method
	if body is TileMapLayer:
		print("Player is hitting terrain")
	if body.is_in_group("BreakableFence"):
		body.take_damage(self)

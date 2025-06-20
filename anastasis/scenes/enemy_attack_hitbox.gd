extends "res://scenes/attack_hitbox.gd"

func _ready():
	defaultLifetime = 0.4

func _on_body_entered(body):
	print("enemy hit")
	if body.is_in_group("player"):
		body.take_damage(self)  # Ensure enemy has this method
		if get_parent() and get_parent().has_method("interrupt_charge"):
			get_parent().interrupt_charge()
			queue_free()
		self.get_parent()
	if body is TileMapLayer:
		print("%s is hitting terrain", [self])

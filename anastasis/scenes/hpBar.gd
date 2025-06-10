extends Control

@export var health: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initHealth(hp: int):
	#set_anchor(hp)
	pass
	
func setHealth(amount: int):
	for i in range(amount):
		print(i)

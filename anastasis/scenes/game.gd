extends Node

@onready var player := %Player
@onready var hud := %HUD
@onready var heart_manager: Node = hud.get_node("HPBar")


func _ready():
	player.health_changed.connect(heart_manager.update_hearts)
	heart_manager.update_hearts(player.health, player.max_health)

extends Node

@onready var player := %Player
@onready var hud := %HUD
@onready var heart_manager: Node = hud.get_node("HPBar")
@onready var gameOverScreen := %GameOver

func _ready():
	player.health_changed.connect(heart_manager.update_hearts)
	heart_manager.update_hearts(player.health, player.max_health)
	player.game_over.connect(self.game_over)

func game_over(over: bool):
	gameOverScreen.show()
	get_tree().paused = true

extends Control

@onready var button := %RestartButton
func _ready():
	hide()  # Hide until game over
func _on_Button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")

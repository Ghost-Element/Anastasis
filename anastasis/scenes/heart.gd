extends Control

@onready var sprite =$AnimatedSprite2D

func _ready():
	rescale_and_center()

func _resized():
	rescale_and_center()

func rescale_and_center():
	# Error case: if animation isn´t set
	if not sprite.sprite_frames.has_animation(sprite.animation):
		return

	# get first texture to get size of image
	var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	if not frame_texture:
		return
	var frame_size = frame_texture.get_size()
	var target_size = size
	# Calculate uniform scale factor (preserve aspect ratio)
	var scale_factor = min(target_size.x / frame_size.x, target_size.y / frame_size.y)
	sprite.scale = Vector2.ONE * scale_factor
	
	# Center the sprite inside the Control
	#var scaled_sprite_size = frame_size * scale_factor
	#(63.33506, 64.0) of (64.0, 64.0)
	sprite.position = size / 2.0 

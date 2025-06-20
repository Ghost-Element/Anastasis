extends CharacterBody2D

signal health_changed(new_health: int, max_health: int)

#func _ready():
	#emit_signal("health_changed", health, max_health)  # sync UI at start
	#print("emitted signal: "+str(health)+" and "+str(max_health))

@export var move_speed: float = 45000.0
@export var attack_hitbox: PackedScene
@export var max_health: int = 5
@export var health: int = 4

@onready var anim := $AnimatedSprite2D

var orientation := Vector2.DOWN

func _process(_delta: float) -> void:
	
	## movement
	# poll input, create vector
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# animation & direction updates based on vector
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		if abs(input_vector.x) > abs(input_vector.y):
			anim.frame = 1 if input_vector.x > 0 else 3
			orientation = Vector2.RIGHT if input_vector.x > 0 else Vector2.LEFT
		else:
			anim.frame = 0 if input_vector.y > 0 else 2
			orientation = Vector2.DOWN if input_vector.y > 0 else Vector2.UP
	
	# movement based on vector
	velocity = input_vector * move_speed * _delta
	move_and_slide()

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.is_action("inventory"): open_Inventory_GUI(); return
		if event.is_action("basic_atk"): do_basic_attack(); return
		if event.is_action("jump"): do_jump(); return
		#print("Unhandled input:", event.as_text()); return
	#print("Not InputEventKey:", event.as_text());

func open_Inventory_GUI():
	return;

func do_basic_attack():
	#check if able to do attack
	var hitbox = attack_hitbox.instantiate()
	hitbox.init_hitbox(Vector2(100,50), orientation, Vector2(200,0))
	add_child(hitbox)
	#start animation
	#slow movement
	#create hitbox
	#call hithandler
	return;

func do_jump():
	print("jumped")
	#velocity = Vector2(0, 10000)
	#move_and_slide()
	return;

func take_damage(dmg: int, sender):
	print("Player took %d damage from %s", [dmg, sender])
	health -= dmg
	print("Current health: %d / %d", [health, max_health])
	#emit_signal("health_changed", health, max_health)

extends CharacterBody2D

signal health_changed(new_health: int, max_health: int)

#func _ready():
	#emit_signal("health_changed", health, max_health)  # sync UI at start
	#print("emitted signal: "+str(health)+" and "+str(max_health))

@export var move_speed: float = 70000.0
@export var attack_hitbox: PackedScene
@export var max_health: int = 5
@export var health: int = 5
@export var drag: float = 0.7 # set to 0.99 for ice physics

@onready var anim := $AnimatedSprite2D

var orientation := Vector2.DOWN
var momentum := Vector2.ZERO

func _process(_delta: float) -> void:
	## movement
	# poll input, create vector
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# animation & direction updates based on vector
	if input_vector.length() > 0:
		momentum = (momentum*drag + input_vector*(0.5+0.5*(1-drag))).normalized()
		if abs(momentum.x) > abs(momentum.y):
			anim.frame = 1 if momentum.x > 0 else 3
		else:
			anim.frame = 0 if momentum.y > 0 else 2
	else:
		momentum *= drag
	# if is currently moving, momentum = orientation. Otherwise keep orientation
	orientation = momentum.normalized() if momentum.length() > 0 else orientation
	# movement based on vector
	velocity = momentum * move_speed * _delta
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
	print("Player took %d damage from %s"% [dmg, sender])
	health -= dmg
	print("Current health: %d / %d"% [health, max_health])
	emit_signal("health_changed", health, max_health)

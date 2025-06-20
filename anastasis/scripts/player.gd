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

@export var abilities = {
	"dash1":1
}
var cooldowns: Dictionary = {}

@onready var anim := $AnimatedSprite2D

var orientation := Vector2.DOWN
var momentum := Vector2.ZERO

var dash_input := Vector2.ZERO

var is_doing_action : bool = false
var is_blocking : bool = false

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
	
	if dash_input.length() > 1:
		velocity = dash_input * move_speed * _delta * (
			1-0.3*int(is_doing_action))  # if attacking slow movement
		dash_input *= 0.8
	else:
		velocity = momentum * move_speed * _delta * (
			1-0.8*int(is_doing_action)) # if attacking slow movement
	move_and_slide()

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.is_action("inventory"): open_Inventory_GUI(); return
		if event.is_action("basic_atk"): do_basic_attack(); return
		if event.is_action("jump"): do_jump(); return
		if event.is_action("heavy_atk"): do_heavy_attack(); return
		if event.is_action("dash1"): do_dash1(); return
		if event.is_action("block"): do_block(); return
	#print("Not InputEventKey:", event.as_text());

func open_Inventory_GUI():
	return

func do_basic_attack():
	if is_doing_action:
		return
	is_doing_action = true
	var hitbox = attack_hitbox.instantiate()
	hitbox.init_hitbox(Vector2(100,50), orientation, Vector2(200,0))
	add_child(hitbox)
	# TODO:animation
	await self.get_tree().create_timer(
		0.4
		).timeout # attack cooldown
	is_doing_action = false
	return

func do_heavy_attack():
	if is_doing_action:
		return
	is_doing_action = true
	await self.get_tree().create_timer(
		0.2
		).timeout # attack windup
	var hitbox = attack_hitbox.instantiate()
	hitbox.init_hitbox(Vector2(100,50), orientation, Vector2(200,0), 0.5, 2, 5)
	add_child(hitbox)
	# TODO: animation
	await self.get_tree().create_timer(
		0.5
		).timeout # attack cooldown
	is_doing_action = false
	return

func do_jump():
	print("jumped")
	#velocity = Vector2(0, 10000)
	#move_and_slide()
	return

func do_dash1():
	if cooldown_manager("dash1"):
		var input_vector := Vector2.ZERO
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		dash_input = input_vector * 5

func do_block():
	if is_doing_action:
		return
	is_doing_action = true
	is_blocking = true
	await self.get_tree().create_timer(
		0.25
		).timeout
	# TODO: animation
	is_blocking = false
	await self.get_tree().create_timer(
		0.35
		).timeout
	is_doing_action = false
	return


func cooldown_manager(ability_name:String) -> bool:
	if not abilities.has(ability_name):
		print("Unknown ability:", ability_name)
		return false
	var now = Time.get_ticks_msec()/float(1000)
	var delta_t_left = now - cooldowns.get(ability_name, -9999) - abilities[ability_name]
	if delta_t_left > 0 or not is_finite(delta_t_left):
		print(delta_t_left)
		cooldowns[ability_name] = now
		return true
	else:
		print("Can't use %s for another %s s" % [ability_name, -delta_t_left])
		return false

func take_damage(sender):
	if not is_blocking:
		print("Player took %d damage from %s"% [sender.damage, sender])
		health -= sender.damage
		if sender.knockback != 0:
			momentum = sender.knockback * Vector2(cos(sender.get_parent().rotation), sin(sender.get_parent().rotation))
		print("Current health: %d / %d"% [health, max_health])
		emit_signal("health_changed", health, max_health)
	else:
		print("blocked %d damage from %s"% [sender.damage, sender])

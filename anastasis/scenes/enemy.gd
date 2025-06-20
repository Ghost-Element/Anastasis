extends CharacterBody2D
@export var speed := 30000
@export var target_node: Node
@export var follow_range: float = 1200
@export var charge_range: float = 700
@export var fighting_range: float = 400
var distance: float
var direction: Vector2 = Vector2.DOWN
@export var attack_hitbox: PackedScene

var idle_timer: float = 0
var attack_timer: float = 0

var charge_timer: float = 0
var has_charge_hitbox: bool = false
var is_charge_interrupted: bool = false
var charge_wait_time: float = 0.7
var charge_charge_time: float = 0.8
var charge_break_time: float = 0.2

# State Machine Variables
enum State { IDLE, FOLLOW, CHARGE, FIGHTING }
var state = State.IDLE
# possible state changes:
# IDLE -> FOLLOW: if distance < follow_range
# FOLLOW -> IDLE: if distance > follow_range
# FOLLOW -> CHARGE: if distance < charge_range
# CHARGE -> ANY: if charge attack is done
# FIGHTING -> CHARGE: if distance > fighting_range
# FOLLOW -> FIGHTING: if distance < fighting_range # if player dashes too close to charge
# FIGHTING -> FOLLOW: if distance > charge_range # if player dashes too far to charge

func _ready():
	# enable to randomize seed
	# randomize()
	pass


func _physics_process(_delta):
	distance = global_position.distance_to(target_node.global_position)
	
	if not target_node:
		print("%s has no target node"[self])
		return
	match state:
		State.IDLE:
			handle_idle(_delta)
		State.FOLLOW:
			handle_follow(_delta)
		State.FIGHTING:
			handle_fighting(_delta)
		State.CHARGE:
			handle_charge(_delta)


func take_damage(sender):
	print("%s took %d damage from %s" % [self.to_string(), sender.damage, sender])
	# TODO:enemy hp management
	# TODO:enemy knockback
	queue_free()

func set_target(target: Node):
	target_node = target

func interrupt_charge():
	is_charge_interrupted = true


func handle_idle(_delta: float):
	idle_timer += _delta
	if(idle_timer>2):
		idle_timer = 0
		# random idle direction (currently does a stupid thing)
		var angle = randf()*TAU
		look_at(global_position + Vector2(cos(angle), sin(angle)).normalized())
		# 20% chance for movement in direction
		if randf() > 0.2:
			velocity = Vector2(cos(self.rotation), sin(self.rotation)) * randf()*speed*_delta
		else:
			velocity = Vector2.ZERO
	move_and_slide()
	# Check for state change
	if distance < follow_range:
		# transition_from_idle()
		# transition_to_follow()
		state = State.FOLLOW
		print("following")


func handle_follow(_delta: float):
	direction = (target_node.global_position - global_position).normalized()
	velocity = direction * speed * _delta
	move_and_slide()
	# Check for state change
	if distance > follow_range:
		# transition_from_follow()
		# transition_to_idle()
		state = State.IDLE
		print("idling")
	elif distance < fighting_range:
		# transition_from_follow()
		# transition_to_fighting()
		state = State.FIGHTING
		print("fighting")
	elif distance < charge_range:
		# transition_from_follow()
		# transition_to_charge()
		state = State.CHARGE
		print("charging")


func handle_fighting(_delta: float):
	look_at(target_node.global_position)
	velocity = Vector2.ZERO
	move_and_slide()
	
	attack_timer += _delta
	if attack_timer > 1.5:
		attack_timer = 0
		# do attack
		var hitbox = attack_hitbox.instantiate()
		hitbox.init_hitbox(Vector2(150,150), Vector2(1,0), Vector2(250,0),0.4,1,1)
		add_child(hitbox)
	
	if distance > charge_range:
		# transition_from_fighting()
		attack_timer = 0
		# transition_to_follow()
		state = State.FOLLOW
		print("following2")
	elif distance > fighting_range:
		# transition_from_fighting()
		# transition_to_charge()
		state = State.CHARGE
		print("charging")


func handle_charge(_delta: float):
	charge_timer += _delta
	# stare phase
	if charge_timer < charge_wait_time:
		look_at(target_node.global_position)
		velocity = Vector2.ZERO
		move_and_slide()
		if fighting_range > distance or distance > follow_range:
			pass # if too close or too far, change state by not returning
		else:
			return
	elif is_charge_interrupted:
		velocity = velocity*0.05
		move_and_slide()
		is_charge_interrupted = false
		# allow state transition by not returning
	elif charge_timer < (charge_wait_time + charge_charge_time):
		if not has_charge_hitbox:
			var hitbox = attack_hitbox.instantiate()
			hitbox.init_hitbox(Vector2(180,120), Vector2(1,0), Vector2(150,0), 0.9, 3, -1)
			add_child(hitbox)
			has_charge_hitbox = true
		direction = (target_node.global_position - global_position).normalized()
		velocity += direction * speed*0.13 * _delta
		move_and_slide()
		return
	elif charge_timer < (charge_wait_time + charge_charge_time + charge_break_time):
		velocity *= 0.95
		move_and_slide()
		return
		
	# Check for state change
	if distance > follow_range:
		transition_from_charge()
		# transition_to_idle()
		state = State.IDLE
		print("idling")
	elif distance < follow_range:
		transition_from_charge()
		#transition_to_follow
		state = State.FOLLOW
		print("following")
	elif distance < fighting_range:
		transition_from_charge()
		# transition_to_fighting()
		state = State.FIGHTING
		print("fighting")
	elif distance < charge_range:
		transition_from_charge()
		# transition_to_charge()
		state = State.CHARGE
		print("charging")

func transition_from_charge():
	charge_timer = 0;
	has_charge_hitbox = false
	is_charge_interrupted = false

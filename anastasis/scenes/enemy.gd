extends CharacterBody2D
@export var speed := 30000
@export var target_node: Node
@export var follow_range: float = 800
@export var fighting_range: float = 400
var distance: float = 1000
var direction: Vector2 = Vector2.DOWN
@export var attack_hitbox: PackedScene

var idle_timer: float = 0
var attack_timer: float = 0

# State Machine Variables
enum State { IDLE, FOLLOW, FIGHTING }
var state = State.IDLE
# possible state changes:
# IDLE -> FOLLOW: if distance < follow_range
# FOLLOW -> IDLE: if distance > follow_range
# FOLLOW -> FIGHTING: if distance < fighting_range
# FIGHTING -> FOLLOW: if distance > fighting_range

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

func take_damage(dmg: int, sender):
	print("%s took %d damage from %s" % [self.to_string(), dmg, sender])
	queue_free()

func set_target(target: Node):
	target_node = target

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
	if distance < fighting_range:
		# transition_from_follow()
		# transition_to_fighting()
		state = State.FIGHTING
		print("fighting")

func handle_fighting(_delta: float):
	look_at(target_node.global_position)
	velocity = Vector2.ZERO
	move_and_slide()
	
	attack_timer += _delta
	if attack_timer > 1.5:
		attack_timer = 0
		# do attack
		var hitbox = attack_hitbox.instantiate()
		hitbox.init_hitbox(Vector2(150,150), Vector2(1,0), Vector2(250,0))
		add_child(hitbox)
	
	if distance > fighting_range:
		# transition_from_fighting()
		attack_timer = 0
		# transition_to_follow()
		state = State.FOLLOW
		print("following2")

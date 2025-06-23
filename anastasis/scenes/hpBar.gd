extends Control

@export var hearts_container: HBoxContainer
@export var heart_scene: PackedScene # set via Inspector

@export var max_health: int = 0
@export var health: int = 0
var hpList: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_hearts(current: int, maximum: int):
	print("Call: update_hearts(current: %d, maximum: %d)"% [current, maximum])
	if(maximum != max_health):
		change_max_health(current, maximum)
	else:
		if(health == current):
			print("Unnecessary call (no update required): update_hearts("+str(current)+", "+str(maximum)+")")
			pass
		elif (health >= current):
			take_dmg(current)
		else:
			regenerate_hp(current)
			

func change_max_health(current: int, maximum: int):
	if(current == maximum):
		regenerate_full()
	var max_previous = max_health
	max_health = maximum # put in frontsssd
	health = current
	if(max_previous < maximum): #gain more hearts
		for i in range(max_previous, maximum):
			var heart = heart_scene.instantiate()
			hearts_container.add_child(heart)
			hpList.append(heart)
	#if(current != maximum): # if not full hp when increasing hp?

	# play animations:
	await get_tree().process_frame
	for i in range(max_previous, maximum):
		await hpList[i].play_animation_till_frame("create", 7)


func take_dmg(current: int):
	if(current<=0):
		#TODO: Die
		pass
	else:
		for i in range(health-1, current-1, -1):
			hpList[i].play_animation("damage")
		health = current

func regenerate_hp(current: int):
	if(current>max_health):
		print("ERROR: call (too much currentHP): regenerate_hp(current = %d) while max = %d"% [current, max_health])
	else:
		for i in range(health-1, max_health-1):
			hpList[i].play_animation("heal")
		health = current

func init_heart():
	pass
	
func regenerate_full():
	if(health == max_health):
		print("Unnecessary call (already full hp): regenerate_full() while hp = "+str(health)+" of max = "+str(max_health))
		pass
	for i in range(health-1, max_health-1):
		hpList[i].play_animation("heal")
	health = max_health

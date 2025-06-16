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
	if(max_health < maximum): #gain more hearts
		for i in range(max_health, maximum):
			var heart = heart_scene.instantiate()
			hearts_container.add_child(heart)
			hpList.append(heart)
	#if(current != maximum): # if not full hp when increasing hp?
	print("Change max health to: "+str(maximum))
	max_health = maximum
	health = current
	pass

func take_dmg(current: int):
	pass

func regenerate_hp(current: int):
	pass

func init_heart():
	pass
	
func regenerate_full():
	if(health == max_health):
		print("Unnecessary call (already full hp): regenerate_full() while hp = "+str(health)+" of max = "+str(max_health))
		pass
	for i in range(health-1, max_health):
		print(i)
		pass

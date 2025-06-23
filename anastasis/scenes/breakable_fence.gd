extends Area2D

var max_hp := 3
var current_hp := max_hp
var tilemap : TileMap
var tile_cell : Vector2i
var atlas_tile_id : int
#
#func _ready():
	## Reference to the TileMap node (set this from outside or find it)
	#tilemap = get_parent().get_paren().get_node("Colision") # shit implementation...
	## Get your tile cell coordinates here (position in TileMap grid)
	#tile_cell = tilemap.local_to_map(tilemap.to_local(global_position))
	#
	## Set the Atlas Tile ID for this fence tile
	#atlas_tile_id = 0  # Replace with your actual tile ID
##
##func take_damage(attacker):
	##current_hp -= 1
	##if current_hp > 0:
		### Update tile animation frame according to damage
		##var tile_data = tilemap.get_cell_tile_data(tile_cell)
		##if tile_data:
			#tile_data.set_animation_frame(max_hp - current_hp)
			#print("Fence damaged! HP:", current_hp)
	#else:
		## Destroy the fence tile
		#tilemap.erase_cell(tile_cell)
		#queue_free()  # Optional: remove this fence node itself
		#print("Fence destroyed!")

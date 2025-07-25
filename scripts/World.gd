# World.gd
extends Node2D

# global variables -------------------------------------------------------------
var view_radius = Settings.view_radius
var tile_size = Settings.tile_size

var portal_location = Vector2i(0, 1)

@onready var player = $"../Player"
@onready var tile_map = $"."

# noise ------------------------------------------------------------------------
@export var noise_tile_texture : NoiseTexture2D
@export var noise_object_texture : NoiseTexture2D
var tile_noise : Noise 
var object_noise : Noise

var provided_seed: int = 0
func set_world_seed(seed: int):
	provided_seed = seed
	
var saved_world_data: Dictionary = {}
func set_world_data(data: Dictionary):
	saved_world_data = data

var generated_tiles = {}
var object_positions = {}
var environment_tiles = {}
var last_player_tile = Vector2i(0, 0)

# tileset ids ------------------------------------------------------------------
var tileset_source_id = 1
var objects_source_id = 0
var portal_source_id = 4

# layers -----------------------------------------------------------------------
var water_layer = 0
var sand_layer = 1
var grass_layer = 2
var cliff_layer = 3
var snow_layer = 4
var environment_layer = 5

# tilesets ---------------------------------------------------------------------
var water_tiles_arr = [];	var terrain_water = 0
var grass_tiles_arr = [];	var terrain_grass = 1
var cliff_tiles_arr = [];	var terrain_cliff = 2
var snow_tiles_arr = [];	var terrain_snow = 3

# atlas tiles ------------------------------------------------------------------
var sand_atlas = [
	Vector2i(0,4), Vector2i(1,4),
	Vector2i(0,5), Vector2i(1,5), Vector2i(2,5), Vector2i(3,5), Vector2i(4,5)
]
var tree_atlas = [
	Vector2i(5,4), Vector2i(5,6)
]
var bush_atlas = [
	Vector2i(5,1), Vector2i(6,1), Vector2i(7,1), Vector2i(8,1), Vector2i(5,3), Vector2i(4,7), Vector2i(4,8), Vector2i(10,5)
]
var pine_atlas = [
	Vector2i(5,8), Vector2i(5,10), Vector2i(4,8)
]
var rock_atlas = [
	Vector2i(5,0), Vector2i(6,0), Vector2i(7,0), Vector2i(8,0)
]
var portal_atlas = [
	Vector2i(0, 0), Vector2i(8, 0)
]

# ------------------------------------------------------------------------------

func _ready():
	await get_tree().process_frame
	player = get_node("../Player")
	
	var character_data = get_parent().character_manager.get_selected_character()
	player.apply_character_data(character_data)
	
	tile_map = self
	tile_noise = noise_tile_texture.noise
	object_noise = noise_object_texture.noise
	
	var seed : int
	if provided_seed != 0:
		seed = provided_seed
	else:
		seed = int(Time.get_unix_time_from_system() * 1000)
	tile_noise.seed = seed
	object_noise.seed = seed
	
	if saved_world_data.has("generated_tiles") and saved_world_data["generated_tiles"].size() > 0:
		restore_world_data()
	
	last_player_tile = get_player_tile()
	generate_world()
	
# ------------------------------------------------------------------------------
	
func _process(_delta):
	var current_player_tile = get_player_tile()
	
	if current_player_tile != last_player_tile:
		update_visible_tiles(current_player_tile)
		last_player_tile = current_player_tile
		
	if current_player_tile.x >= -2 and current_player_tile.x <= 1 and current_player_tile.y == -1 and current_player_tile.y <= 1:
		if get_parent().get_current_playtime() >= 600.0:
			var interface = player.get_node_or_null("Camera/Interface")
			interface._show_victory_screen()
		
# ------------------------------------------------------------------------------

func get_player_tile():
	var player_pos = player.position / tile_size
	return Vector2i(floor(player_pos.x), floor(player_pos.y))
	
# ------------------------------------------------------------------------------

func restore_world_data():
	var portal_spawned = true
	if saved_world_data.has("generated_tiles"):
		generated_tiles = saved_world_data["generated_tiles"]
	
	if saved_world_data.has("object_positions"):
		object_positions = saved_world_data["object_positions"]
		
	if saved_world_data.has("tile_arrays"):
		var arrays = saved_world_data["tile_arrays"]
		if arrays.has("water_tiles_arr"):
			water_tiles_arr = arrays["water_tiles_arr"]
		if arrays.has("grass_tiles_arr"):
			grass_tiles_arr = arrays["grass_tiles_arr"]
		if arrays.has("cliff_tiles_arr"):
			cliff_tiles_arr = arrays["cliff_tiles_arr"]
		if arrays.has("snow_tiles_arr"):
			snow_tiles_arr = arrays["snow_tiles_arr"]

	rebuild_tilemap_from_data()

# ------------------------------------------------------------------------------

func rebuild_tilemap_from_data():
	for layer in [water_layer, sand_layer, grass_layer, cliff_layer, snow_layer, environment_layer]:
		tile_map.clear_layer(layer)
	
	if water_tiles_arr.size() > 0:
		tile_map.set_cells_terrain_connect(water_layer, water_tiles_arr, terrain_water, 0)
	if grass_tiles_arr.size() > 0:
		tile_map.set_cells_terrain_connect(grass_layer, grass_tiles_arr, terrain_grass, 0)
	if cliff_tiles_arr.size() > 0:
		tile_map.set_cells_terrain_connect(cliff_layer, cliff_tiles_arr, terrain_cliff, 0)
	if snow_tiles_arr.size() > 0:
		tile_map.set_cells_terrain_connect(snow_layer, snow_tiles_arr, terrain_snow, 0)

	for tile_pos in generated_tiles.keys():
		var tile_noise_value = tile_noise.get_noise_2d(tile_pos.x, tile_pos.y)
		var object_noise_value = object_noise.get_noise_2d(tile_pos.x, tile_pos.y)

		if tile_noise_value > -0.35 and tile_noise_value <= -0.32:
			var random_sand = sand_atlas[randi() % sand_atlas.size()]
			tile_map.set_cell(sand_layer, tile_pos, tileset_source_id, random_sand)

		if object_positions.has(tile_pos):
			if tile_noise_value > 0.27 and tile_noise_value < 0.33:
				if object_noise_value > 0.75:
					tile_map.set_cell(environment_layer, tile_pos, objects_source_id, pine_atlas.pick_random())
				elif object_noise_value > 0.50:
					tile_map.set_cell(environment_layer, tile_pos, objects_source_id, rock_atlas.pick_random())
			elif tile_noise_value > -0.30 and tile_noise_value < 0.10:
				if object_noise_value > 0.70:
					tile_map.set_cell(environment_layer, tile_pos, objects_source_id, tree_atlas.pick_random())
				elif object_noise_value > 0.60:
					tile_map.set_cell(environment_layer, tile_pos, objects_source_id, bush_atlas.pick_random())
	
# ------------------------------------------------------------------------------
	
func update_visible_tiles(player_tile):
	var new_sand = []
	var new_grass = []
	var new_cliff = []
	var new_snow = []
	var new_water = []
	
# - generate terrain -----------------------------------------------------------
	for x in range(player_tile.x - view_radius, player_tile.x + view_radius + 1):
		for y in range(player_tile.y - view_radius, player_tile.y + view_radius + 1):
			var tile_pos = Vector2i(x, y)
			if not generated_tiles.has(tile_pos):
				var tile_noise_value : float = tile_noise.get_noise_2d(x, y)
				var object_noise_value : float = object_noise.get_noise_2d(x, y)

# ------------- snow -----------------------------------------------------------				
				if tile_noise_value > 0.40:
					new_snow.append(tile_pos)
					snow_tiles_arr.append(tile_pos)
# ------------- cliff ----------------------------------------------------------
				if tile_noise_value > 0.20:
					new_cliff.append(tile_pos)
					cliff_tiles_arr.append(tile_pos)
					if tile_noise_value > 0.27 and tile_noise_value < 0.33:
# ----------------- cliff environment object "pine" ----------------------------
						if object_noise_value > 0.75 and not is_spawn_area(Vector2i(x, y)):
							var can_place_pine = true
							for dx in range(2):
								for dy in range(2):
									var check_pos = Vector2i(x + dx, y + dy)
									if object_positions.has(check_pos):
										can_place_pine = false
										break
							if can_place_pine:
								tile_map.set_cell(environment_layer, Vector2i(x, y), objects_source_id, pine_atlas.pick_random())
								for dx in range(2): # mark tiles as occupied
									for dy in range(2):
										object_positions[Vector2i(x + dx, y + dy)] = true
# ----------------- cliff environment object "rock" ----------------------------
						if object_noise_value > 0.50 and not is_spawn_area(Vector2i(x, y)):
							var can_place_rock = true
							var check_pos = Vector2i(x, y)
							if object_positions.has(check_pos):
								can_place_rock = false
							if can_place_rock:
								tile_map.set_cell(environment_layer, Vector2i(x, y), objects_source_id, rock_atlas.pick_random())
								object_positions[Vector2i(x, y)] = true
# ------------- grass ----------------------------------------------------------
				if tile_noise_value > -0.32:
					new_grass.append(tile_pos)
					grass_tiles_arr.append(tile_pos)
# ----------------- grass environment object "tree" ----------------------------
					if tile_noise_value > -0.30 and tile_noise_value < 0.10:
						if object_noise_value > 0.70 and not is_spawn_area(Vector2i(x, y)):
							var can_place_tree = true
							for dx in range(2):
								for dy in range(2):
									var check_pos = Vector2i(x + dx, y + dy)
									if object_positions.has(check_pos):
										can_place_tree = false
										break
							if can_place_tree:
								tile_map.set_cell(environment_layer, Vector2i(x, y), objects_source_id, tree_atlas.pick_random())
								for dx in range(2): # mark tiles as occupied
									for dy in range(2):
										object_positions[Vector2i(x + dx, y + dy)] = true
# ----------------- grass environment object "bush" ----------------------------
						if object_noise_value > 0.60 and not is_spawn_area(Vector2i(x, y)):
							var can_place_bush = true
							var check_pos = Vector2i(x, y)
							if object_positions.has(check_pos):
								can_place_bush = false
							if can_place_bush:
								tile_map.set_cell(environment_layer, Vector2i(x, y), objects_source_id, bush_atlas.pick_random())
								object_positions[Vector2i(x, y)] = true
# ------------- sand -----------------------------------------------------------
				elif tile_noise_value > -0.35:
					new_sand.append(tile_pos)
# ------------- water ----------------------------------------------------------
				else:
					new_water.append(tile_pos)
					water_tiles_arr.append(tile_pos)
# ------------- mark tile location as generated --------------------------------
				generated_tiles[tile_pos] = true

# - place tiles from tiles arrays ----------------------------------------------
	if new_sand.size() > 0: 	# sand
		for pos in new_sand:
			var random_sand = sand_atlas[randi() % sand_atlas.size()]
			tile_map.set_cell(sand_layer, pos, tileset_source_id, random_sand)
	if new_grass.size() > 0: 	# grass
		tile_map.set_cells_terrain_connect(grass_layer, new_grass, terrain_grass, 0)
	if new_cliff.size() > 0:	# cliff
		tile_map.set_cells_terrain_connect(cliff_layer, new_cliff, terrain_cliff, 0)
	if new_snow.size() > 0:		# snow
		tile_map.set_cells_terrain_connect(snow_layer, new_snow, terrain_snow, 0)
	if new_water.size() > 0:	# water
		tile_map.set_cells_terrain_connect(water_layer, new_water, terrain_water, 0)
		
	if get_parent().get_current_playtime() >= 600.0:
		tile_map.set_cell(environment_layer, Vector2i(0, 1), portal_source_id, portal_atlas[1])
	else:
		tile_map.set_cell(environment_layer, Vector2i(0, 1), portal_source_id, portal_atlas[0])

# ------------------------------------------------------------------------------

func generate_world():
	update_visible_tiles(last_player_tile)
	
# ------------------------------------------------------------------------------

func is_position_valid(world_position: Vector2) -> bool:
	var tile_pos = Vector2i(floor(world_position.x / tile_size), floor(world_position.y / tile_size))
	return generated_tiles.has(tile_pos)

func is_spawn_area(pos: Vector2i, width: int = 1, height: int = 1) -> bool:
	for dx in range(width):
		for dy in range(height):
			if pos.x >= -3 and pos.x <= 2 and pos.y >= -1 and pos.y <= 1:
				return true
	return false

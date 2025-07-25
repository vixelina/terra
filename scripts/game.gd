# game.gd
extends Node2D

var character_manager = null
var selected_character_id = ""
var world_seed = 0
var world_data = {}
var player_start_position = Vector2.ZERO
var player_health = 0.0
var current_save_slot = -1
var playtime_start: float = 0.0 
var total_playtime: float = 0.0

func _ready():
	character_manager = load("res://scripts/CharacterManagement/CharacterManager.gd").new()
	add_child(character_manager)
	
	character_manager._ready()
	character_manager.select_character(selected_character_id)
	
	var world = get_node("TileMap")
	world.set_world_seed(world_seed)
	world.set_world_data(world_data)
	
	if player_start_position != Vector2.ZERO:
		var player_node = get_node("Player")
		player_node.global_position = player_start_position
	
	if player_health > 0.0:
		var player_node = get_node("Player")
		var health_component = player_node.get_node_or_null("HealthComponent")
		if health_component:
			health_component.health = player_health
			health_component.update_health_bar()
			
	playtime_start = Time.get_unix_time_from_system()
	
func get_current_playtime() -> float:
	var current_session_time = Time.get_unix_time_from_system() - playtime_start
	return total_playtime + current_session_time
	
func set_params(params):
	if params.has("character_id"):
		selected_character_id = params.character_id
	if params.has("world_seed"):
		world_seed = params.world_seed
	if params.has("world_data"):
		world_data = params.world_data
	if params.has("player_position"):
		player_start_position = params.player_position
	if params.has("player_health"):
		player_health = params.player_health
	if params.has("load_slot"):
		current_save_slot = params.load_slot
	if params.has("playtime"):
		total_playtime = params.playtime

func save_game():
	if current_save_slot == -1:
		print("Error: No save slot assigned!")
		return

	var current_session_time = Time.get_unix_time_from_system() - playtime_start
	var updated_playtime = total_playtime + current_session_time

	var player_node = get_node("Player")
	var player_position = player_node.global_position
	
	var player_health = 100.0
	var health_component = player_node.get_node_or_null("HealthComponent")
	player_health = health_component.health

	var world_node = get_node("TileMap")
	var world_data = {}
	world_data = {
		"generated_tiles": world_node.generated_tiles,
		"object_positions": world_node.object_positions,
		"tile_arrays": {
			"water_tiles_arr": world_node.water_tiles_arr,
			"grass_tiles_arr": world_node.grass_tiles_arr,
			"cliff_tiles_arr": world_node.cliff_tiles_arr,
			"snow_tiles_arr": world_node.snow_tiles_arr
		}
	}

	var save_game = SaveGame.new()
	save_game.character_id = selected_character_id
	save_game.global_position = player_position
	save_game.playtime = updated_playtime
	save_game.player_health = player_health
	save_game.world_seed = world_seed
	save_game.world_data = world_data

	save_game.write_savegame(current_save_slot)

	total_playtime = updated_playtime
	playtime_start = Time.get_unix_time_from_system()

# SaveManager.gd
class_name SaveManager
extends RefCounted

const MAX_SAVE_SLOTS = 3

# check all save slots --------------------------------------------------------
static func get_save_info(slot_index: int) -> Dictionary:
	var save_game = SaveGame.load_savegame(slot_index)
	if save_game:
		return {
			"exists": true,
			"character_id": save_game.character_id,
			"playtime": save_game.playtime,
			"timestamp": save_game.save_timestamp,
			"world_seed": save_game.world_seed,
			"global_position": save_game.global_position,
			"player_health": save_game.player_health
		}
	else:
		return {
			"exists": false,
			"character_id": "",
			"playtime": 0.0,
			"timestamp": "",
			"world_seed": 0,
			"global_position": Vector2.ZERO,
			"player_health": 100.0
		}

# find first empty slot -------------------------------------------------------
static func find_empty_slot() -> int:
	for i in range(MAX_SAVE_SLOTS):
		if not SaveGame.save_exists(i):
			return i
	return -1 

# create new save in first empty slot -----------------------------------------
static func create_new_save(character_id: String, world_seed: int) -> int:
	var slot_index = find_empty_slot()
	if slot_index == -1:
		print("All save slots are occupied!")
		return -1
	
	var new_save = SaveGame.new()
	new_save.character_id = character_id
	new_save.global_position = Vector2.ZERO
	new_save.playtime = 0.0
	new_save.player_health = 100.0
	new_save.world_seed = world_seed
	new_save.world_data = {
		"generated_tiles": {},
		"object_positions": {},
		"tile_arrays": {
			"water_tiles_arr": [],
			"grass_tiles_arr": [],
			"cliff_tiles_arr": [],
			"snow_tiles_arr": []
		}
	}
	new_save.write_savegame(slot_index)
	
	return slot_index

# format playtime --------------------------------------------------------------
static func format_time(seconds: float) -> String:
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	var secs = int(seconds) % 60
	return "%02dh%02dm%02ds" % [hours, minutes, secs]

# ------------------------------------------------------------------------------

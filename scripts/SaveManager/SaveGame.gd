# SaveGame.gd
class_name SaveGame
extends Resource

# save data --------------------------------------------------------------------
@export var character_id: String = ""
@export var global_position: Vector2 = Vector2.ZERO
@export var playtime: float = 0.0
@export var player_health: float = 100.0
@export var world_seed: int = 0
@export var world_data: Dictionary = {}
@export var save_timestamp: String = ""
@export var is_occupied: bool = false

# ------------------------------------------------------------------------------

func write_savegame(slot_index: int) -> void:
	save_timestamp = Time.get_datetime_string_from_system()
	is_occupied = true
	var save_path = "user://savegame_slot_%d.tres" % slot_index
	ResourceSaver.save(self, save_path)
	print("Game saved to slot ", slot_index)

static func load_savegame(slot_index: int) -> SaveGame:
	var save_path = "user://savegame_slot_%d.tres" % slot_index
	if ResourceLoader.exists(save_path):
		var save_game = load(save_path) as SaveGame
		if save_game and save_game.is_occupied:
			return save_game
	return null

static func save_exists(slot_index: int) -> bool:
	var save_path = "user://savegame_slot_%d.tres" % slot_index
	if ResourceLoader.exists(save_path):
		var save_game = load(save_path) as SaveGame
		return save_game != null and save_game.is_occupied
	return false

static func delete_save(slot_index: int) -> void:
	var save_path = "user://savegame_slot_%d.tres" % slot_index
	if ResourceLoader.exists(save_path):
		DirAccess.remove_absolute(save_path)

# ------------------------------------------------------------------------------

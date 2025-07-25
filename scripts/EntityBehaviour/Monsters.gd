# Monsters.gd
extends RefCounted
class_name Monsters

static var monster_data = {}

static func _load_monster_data():
	if monster_data.is_empty():
		var dir = DirAccess.open("res://resources/monsters/")
		dir.list_dir_begin()
		var file_name = dir.get_next()
			
		while file_name != "":
			if file_name.ends_with(".tres"):
				var monster_id = file_name.get_basename().to_lower()
				var monster_resource = load("res://resources/monsters/" + file_name)
				if monster_resource:
					monster_data[monster_id] = monster_resource
				
			file_name = dir.get_next()
		
		dir.list_dir_end()

# spawning logic ---------------------------------------------------------------

static func spawn_from_tile(atlas_coords: Vector2i, tile_pos: Vector2i, world: Node2D, parent: Node) -> bool:
	_load_monster_data()
	
	match atlas_coords:
		Vector2i(10, 5):  # Mushy
			return _spawn_monster_by_id("mushy", tile_pos, world, parent)
		_:
			return false

static func spawn_random_monster(tile_pos: Vector2i, world: Node2D, parent: Node) -> bool:
	_load_monster_data()
	
	var biome = _get_biome_at_position(tile_pos, world)
	var valid_monsters = _get_monsters_for_biome(biome)
	
	if valid_monsters.is_empty():
		return false

	var weighted_monsters: Array[String] = []
	for monster_id in valid_monsters:
		var data = monster_data[monster_id]
		var weight = int(data.spawn_rarity * 10)
		for i in weight:
			weighted_monsters.append(monster_id)
	
	if weighted_monsters.is_empty():
		return false
	
	var selected_monster = weighted_monsters.pick_random()
	return _spawn_monster_by_id(selected_monster, tile_pos, world, parent)

static func _spawn_monster_by_id(monster_id: String, tile_pos: Vector2i, world: Node2D, parent: Node) -> bool:
	var monster_scene = preload("res://scenes/enemies/Monster.tscn")
	var monster_data = monster_data.get(monster_id)
	
	if not monster_scene or not monster_data:
		return false
	
	var monster_instance = monster_scene.instantiate()
	var spawn_position = Vector2(tile_pos.x * world.tile_size + world.tile_size/2, tile_pos.y * world.tile_size + world.tile_size/2)
	monster_instance.position = spawn_position

	monster_instance.apply_monster_data(monster_data)
	
	parent.add_child(monster_instance)
	return true
	
# biome logic ------------------------------------------------------------------

static func _get_biome_at_position(tile_pos: Vector2i, world: Node2D) -> String:
	var tile_noise_value = world.tile_noise.get_noise_2d(tile_pos.x, tile_pos.y)

	if tile_noise_value > 0.40:
		return "snow"
	elif tile_noise_value > 0.20:
		return "mountain"
	elif tile_noise_value > -0.32:
		return "grass"
	elif tile_noise_value > -0.35:
		return "sand"
	else:
		return "water"

static func _get_monsters_for_biome(biome: String) -> Array[String]:
	_load_monster_data()
	
	var valid_monsters: Array[String] = []
	for monster_id in monster_data.keys():
		var data = monster_data[monster_id]
		if data.preferred_biomes.is_empty() or biome in data.preferred_biomes:
			valid_monsters.append(monster_id)
	
	return valid_monsters

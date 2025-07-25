# MonsterSpawner.gd
extends Node
class_name MonsterSpawner

@export var spawn_radius: int = 10
@export var base_spawn_interval: float = 10.0
@export var min_spawn_interval: float = 1
@export var spawn_scaling: float = 0.8
@export var max_monsters: int = 200
@export var despawn_distance: float = 300.0

@onready var world = $"../TileMap"
@onready var player = $"../Player"
@onready var game = get_parent()

var spawn_timer: Timer
var despawn_timer: Timer
var last_spawn_time: float = 0.0

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_attempt_monster_spawn)
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	
	despawn_timer = Timer.new()
	despawn_timer.wait_time = 5.0
	despawn_timer.timeout.connect(_attempt_monster_despawn)
	despawn_timer.autostart = true
	add_child(despawn_timer)
	
	call_deferred("_start_timed_spawning")

func _start_timed_spawning():
	_update_spawn_interval()

func _process(delta):
	var current_playtime = game.get_current_playtime()

	if int(current_playtime) % 60 == 0 and current_playtime > last_spawn_time + 60:
		_update_spawn_interval()
		last_spawn_time = current_playtime

func _update_spawn_interval():
	var current_playtime = game.get_current_playtime()
	var minutes_played = current_playtime / 60.0
	var current_interval = base_spawn_interval * pow(spawn_scaling, minutes_played)
	current_interval = max(current_interval, min_spawn_interval)
	
	spawn_timer.wait_time = current_interval
	if spawn_timer.is_stopped():
		spawn_timer.start()
	
	print("Playtime: ", SaveManager.format_time(current_playtime), " - Spawn interval: ", current_interval, "s")

func _attempt_monster_spawn():
	var current_monsters = get_children().filter(func(child): return child is Monster)
	if current_monsters.size() >= max_monsters:
		return

	var spawn_count = _calculate_spawn_count()
	
	for i in spawn_count:
		_spawn_single_monster()

func _attempt_monster_despawn():
	if not player:
		return
		
	var player_pos = player.global_position
	var monsters_to_remove = []

	for child in get_children():
		if child is Monster:
			var distance = child.global_position.distance_to(player_pos)
			if distance >= despawn_distance:
				monsters_to_remove.append(child)
	
	for monster in monsters_to_remove:
		monster.queue_free()
		
func _calculate_spawn_count() -> int:
	var current_playtime = game.get_current_playtime()
	var minutes_played = current_playtime / 60.0
	
	if minutes_played < 2:
		return 1
	elif minutes_played < 5:
		return randi_range(1, 2)
	elif minutes_played < 10:
		return randi_range(2, 3)
	else:
		return randi_range(3, 5)

func _spawn_single_monster():
	var player_tile = world.get_player_tile()
	var valid_positions = _get_valid_spawn_positions(player_tile)
	
	var spawn_pos = valid_positions.pick_random()
	var success = Monsters.spawn_random_monster(spawn_pos, world, self)
	if success:
		var current_playtime = game.get_current_playtime()

func tile_attack(world_position: Vector2):
	if not world:
		return
		
	var tile_pos = Vector2i(floor(world_position.x / world.tile_size), floor(world_position.y / world.tile_size))

	var tile_data = world.get_cell_source_id(world.environment_layer, tile_pos)
	if tile_data == -1:
		return

	var atlas_coords = world.get_cell_atlas_coords(world.environment_layer, tile_pos)

	if Monsters.spawn_from_tile(atlas_coords, tile_pos, world, self):
		world.erase_cell(world.environment_layer, tile_pos)
		if world.object_positions.has(tile_pos):
			world.object_positions.erase(tile_pos)

func _get_valid_spawn_positions(player_tile: Vector2i) -> Array[Vector2i]:
	var valid_positions: Array[Vector2i] = []
	
	for x in range(player_tile.x - spawn_radius, player_tile.x + spawn_radius + 1):
		for y in range(player_tile.y - spawn_radius, player_tile.y + spawn_radius + 1):
			var tile_pos = Vector2i(x, y)

			if world.generated_tiles.has(tile_pos) and not world.object_positions.has(tile_pos):
				if tile_pos.distance_to(player_tile) > 3:
					var tile_noise_value = world.tile_noise.get_noise_2d(x, y)
					if tile_noise_value > -0.35:
						valid_positions.append(tile_pos)
	
	return valid_positions

# MonsterData.gd
extends Resource
class_name MonsterData

@export var monster_id: String
@export var monster_sprite_frames: SpriteFrames
@export var health: float = 100.0

@export var melee_weapon_frames: SpriteFrames
@export var melee_damage: float = 15.0

@export var weapon_collision_v: PackedVector2Array
@export var weapon_collision_h: PackedVector2Array

@export var move_speed: float = 80.0
@export var attack_range: float = 32.0
@export var detection_range: float = 100.0
@export var is_flying: bool = false

@export var preferred_biomes: Array[String] = []
@export var spawn_rarity: float = 1.0  # 0.0 = never, 1.0 = common

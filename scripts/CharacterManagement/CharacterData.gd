# CharacterData.gd
extends Resource
class_name CharacterData

@export var character_id: String
@export var character_sprite_frames: SpriteFrames
@export var health: float = 100.0

@export var melee_weapon_frames: SpriteFrames
@export var melee_damage: float = 20.0

@export var ranged_attacks: Array[RangedAttackData] = []
@export var default_ranged_index: int = 0

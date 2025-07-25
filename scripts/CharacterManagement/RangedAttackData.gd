# RangedAttackData.gd
extends Resource
class_name RangedAttackData

@export var attack_id: String
@export var ranged_frames: SpriteFrames
@export var collision_shape: Shape2D
@export var offset: Vector2 = Vector2.ZERO
@export var damage: float = 10.0
@export var speed: float = 400.0
@export var cooldown: float = 1.0
@export var knockback: float = 10.0
@export var travel_distance: float = 500.0

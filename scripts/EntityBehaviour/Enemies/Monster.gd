# Monster.gd
extends Entity
class_name Monster

@onready var melee_weapon = $MeleeWeapon
@onready var hitbox_component = $HitboxComponent

var current_monster_id: String
var detection_range: float
var attack_range: float
var is_flying: bool

func apply_monster_data(monster_data: MonsterData):	
	current_monster_id = monster_data.monster_id

	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.sprite_frames = monster_data.monster_sprite_frames

	var weapon = get_node_or_null("MeleeWeapon")
	if weapon:
		var weapon_sprite = weapon.get_node_or_null("AnimatedSprite2D")
		if weapon_sprite:
			weapon_sprite.sprite_frames = monster_data.melee_weapon_frames

		weapon.attack_damage = monster_data.melee_damage

		var weapon_collision_v = weapon.get_node_or_null("CollisionPolygon2D_V")
		if weapon_collision_v:
			weapon_collision_v.polygon = monster_data.weapon_collision_v
			
		var weapon_collision_h = weapon.get_node_or_null("CollisionPolygon2D_H")
		if weapon_collision_h:
			weapon_collision_h.polygon = monster_data.weapon_collision_h

	var hitbox = get_node_or_null("HitboxComponent")
	if hitbox:
		hitbox.damage_amount = monster_data.melee_damage
		
	health = monster_data.health
	speed = monster_data.move_speed
	detection_range = monster_data.detection_range
	attack_range = monster_data.attack_range
	
	is_flying = monster_data.is_flying
	_setup_collision_layers()
	
func _setup_collision_layers():
	collision_layer = 2
	
	if is_flying:
		collision_mask = 2
	else:
		collision_mask = 1 | 2 | 3 | 4 | 5

func get_detection_range() -> float:
	return detection_range

func get_attack_range() -> float:
	return attack_range

func is_flying_monster() -> bool:
	return is_flying
	

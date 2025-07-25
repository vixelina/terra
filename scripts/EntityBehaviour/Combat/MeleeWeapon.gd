# MeleeWeapon.gd
extends Weapon
class_name MeleeWeapon

@export var knockback_force : float = 100.0

var hit_targets = []

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_v = $CollisionPolygon2D_V
@onready var collision_h = $CollisionPolygon2D_H

func _ready():
	area_entered.connect(_on_hitbox_area_entered)
	
	animated_sprite.visible = false
	collision_v.disabled = true
	collision_h.disabled = true

func start_attack(direction, source_entity):
	attacker = source_entity
	is_active = true
	hit_targets.clear()
	
	animated_sprite.visible = true
	var anim_name = ""
	if abs(direction.x) > abs(direction.y):
		anim_name = "melee_right" if direction.x > 0 else "melee_left"
	else:
		anim_name = "melee_down" if direction.y > 0 else "melee_up"
					
	if animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
	
	setup_collision(direction)
	
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

func setup_collision(direction):
	collision_v.disabled = true
	collision_h.disabled = true
	
	if abs(direction.x) > abs(direction.y):
		collision_h.disabled = false
		
		if direction.x > 0: # right
			collision_h.scale.x = -1
		else: # left
			collision_h.scale.x = 1
	else:
		collision_v.disabled = false
		
		if direction.y < 0: # up
			collision_v.scale.y = -1
			collision_v.scale.x = -1
			collision_v.position.y = -16.0
		else: # down
			collision_v.scale.y = 1
			collision_v.scale.x = 1
			collision_v.position.y = 0.0

func _on_hitbox_area_entered(area):
	if !is_active:
		return
	
	if hit_targets.has(area):
		return
	
	var area_parent = area.get_parent()
	if area_parent == attacker:
		return
	
	if area is HitboxComponent:
		hit_targets.append(area)
		
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.attack_position = attacker.global_position
		
		var target_pos = area_parent.global_position
		attack.knockback_direction = (target_pos - attacker.global_position).normalized()
		attack.knockback_force = knockback_force
		attack.attack_type = "melee"
		
		area.damage(attack)

func _on_animation_finished():
	end_attack()

func end_attack():
	is_active = false
	hit_targets.clear()
	
	animated_sprite.visible = false
	
	if animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
	
	collision_v.disabled = true
	collision_v.position.y = 0.0
	collision_h.disabled = true

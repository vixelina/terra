# HitboxComponent.gd
extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent
@export var damage_amount : float = 10.0
@export var can_damage_player : bool = true
@export var knockback_force : float = 100.0

static var player_hit_time : int = 0
static var player_invulnerability_time : int = 500  # invulnerability period (ms)

func _physics_process(delta):
	var parent = get_parent()
	
	if parent.name == "Player" or !can_damage_player:
		return
		
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area is HitboxComponent:
			var other_parent = area.get_parent()
			
			if other_parent.name == "Player":
				var current_time = Time.get_ticks_msec()
				if current_time - player_hit_time < player_invulnerability_time:
					return
				
				player_hit_time = current_time
				
				var attack = Attack.new()
				attack.attack_damage = damage_amount
				attack.attack_position = global_position
				
				var player_pos = other_parent.global_position
				attack.knockback_direction = (player_pos - parent.global_position).normalized()
				attack.knockback_force = knockback_force
				attack.attack_type = "collision"
				
				area.damage(attack)
				
				return

func damage(attack : Attack):
	var parent = get_parent()
	
	parent.set_meta("last_attack", attack)
	parent.set_meta("hit_source_position", attack.attack_position)
	
	parent.is_hit = true
		
	health_component.damage(attack)

# Attack.gd
class_name Attack

var attack_damage : float
var attack_position : Vector2
var knockback_force : float = 0.0
var knockback_direction : Vector2 = Vector2.ZERO
var attack_type : String = "default"  # "melee", "projectile", "collision", "magic"

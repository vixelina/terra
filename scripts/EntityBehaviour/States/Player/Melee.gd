# Melee.gd
extends State
class_name PlayerMelee

func Enter():
	animated_sprite = entity.animated_sprite
	
	var input_direction = entity.get_input_direction()
	
	entity.velocity = Vector2.ZERO
	
	Animate("melee", input_direction)
	
	var attack_direction = Vector2.ZERO
	match entity.current_direction:
		Direction.UP: attack_direction = Vector2(0, -1)
		Direction.DOWN: attack_direction = Vector2(0, 1)
		Direction.LEFT: attack_direction = Vector2(-1, 0)
		Direction.RIGHT: attack_direction = Vector2(1, 0)
	
	var melee_weapon = entity.get_node("MeleeWeapon")
	melee_weapon.start_attack(attack_direction, entity)
	
	await animated_sprite.animation_finished
	
	var current_input = entity.get_input_direction()
	if current_input.length() > 0:
		Transitioned.emit(self, "walk")
	else:
		Transitioned.emit(self, "idle")

func Physics_Update(delta):
	entity.velocity = Vector2.ZERO

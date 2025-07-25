# Cast.gd
extends State
class_name PlayerCast

var weapon_scene = preload("res://scenes/Objects/RangedWeapon.tscn")

func Enter():
	animated_sprite = entity.animated_sprite
	
	var cursor_position = entity.get_global_mouse_position()
	var input_direction = (cursor_position - entity.global_position).normalized()

	Animate("cast", input_direction)
	entity.velocity = Vector2.ZERO

	var current_attack_data = entity.get_current_ranged_attack()
	var parent_node = entity.get_node("../TileMap").get_parent()
	var weapon = weapon_scene.instantiate()
	parent_node.add_child(weapon)

	if entity.is_magic_character():
		weapon.initialize_as_magic(cursor_position, entity, current_attack_data)
		entity.next_ranged_attack()
	else:
		weapon.global_position = entity.global_position
		var direction = (cursor_position - entity.global_position).normalized()
		weapon.rotation = atan2(direction.y, direction.x)
		weapon.initialize_as_projectile(direction, cursor_position, entity, current_attack_data)

	weapon.start()

	await get_tree().create_timer(0.2).timeout
	Transitioned.emit(self, "idle")

func Physics_Update(delta):
	entity.velocity = Vector2.ZERO

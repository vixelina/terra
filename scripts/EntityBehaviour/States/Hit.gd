# Hit.gd
extends State
class_name EntityHit

@export var knockback_duration: float = 0.3
@export var knockback_force: float = 50.0

var knockback_timer: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO
var hit_source_position: Vector2 = Vector2.ZERO
var hit_completed: bool = false

func Enter():
	animated_sprite = entity.animated_sprite
		
	var attack = null
	if entity.has_meta("last_attack"):
		attack = entity.get_meta("last_attack")
	
	if attack:
		knockback_direction = attack.knockback_direction
		
		var force = attack.knockback_force
		if force > 0:
			knockback_force = force
		
		if attack.attack_type == "melee":
			knockback_duration = 0.4
		elif attack.attack_type == "projectile":
			knockback_duration = 0.3
		elif attack.attack_type == "collision":
			knockback_duration = 0.2
		elif attack.attack_type == "magic":
			knockback_duration = 0.1
	
	elif entity.has_meta("hit_source_position"):
		hit_source_position = entity.get_meta("hit_source_position")
		knockback_direction = (entity.global_position - hit_source_position).normalized()
	
	if abs(knockback_direction.x) >= abs(knockback_direction.y):
		entity.current_direction = Direction.RIGHT if knockback_direction.x > 0 else Direction.LEFT
	else:
		entity.current_direction = Direction.DOWN if knockback_direction.y > 0 else Direction.UP
	
	entity.velocity = knockback_direction * knockback_force
	
	knockback_timer = knockback_duration
	
	Animate("hit", knockback_direction)
	
	if animated_sprite and !animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	hit_completed = false

func Physics_Update(delta):
	knockback_timer -= delta
	
	if knockback_timer > 0:
		entity.move_and_slide()
	
	if hit_completed:
		Exit()
		
		if entity.name == 'Player':
			var current_input = entity.get_input_direction()
			if current_input.length() > 0:
				Transitioned.emit(self, "walk")
			else:
				Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "wander")

func Exit():
	entity.is_hit = false
	entity.velocity = Vector2.ZERO
	
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
	
	if entity.has_meta("hit_source_position"):
		entity.remove_meta("hit_source_position")

func _on_animation_finished():
	if animated_sprite and animated_sprite.animation.begins_with("hit_"):
		hit_completed = true

# Jump.gd
extends State
class_name PlayerJump

var jump_speed
var input_direction = Vector2.ZERO
var jump_completed = false

func Enter():
	animated_sprite = entity.animated_sprite
	
	var player = entity
	jump_speed = player.speed / 2.5

	input_direction = player.get_input_direction()

	player.is_jumping = true
	player.set_collision_mask_value(3, false)
	
	if input_direction.length() > 0:
		if abs(input_direction.x) >= abs(input_direction.y):
			player.current_direction = Direction.RIGHT if input_direction.x > 0 else Direction.LEFT
		else:
			player.current_direction = Direction.DOWN if input_direction.y > 0 else Direction.UP
	
	if input_direction.length() > 0:
		player.velocity = input_direction * jump_speed
	else:
		player.velocity = Vector2.ZERO
	
	Animate("jump", input_direction)
	
	if animated_sprite and !animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	jump_completed = false

func Physics_Update(delta):
	var player = entity
	
	if !jump_completed:
		player.move_and_slide()
	else:
		Exit()
		
		var current_input = player.get_input_direction()
		if current_input.length() > 0:
			Transitioned.emit(self, "walk")
		else:
			Transitioned.emit(self, "idle")

func Exit():
	var player = entity
	
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
	
	player.is_jumping = false
	player.velocity = Vector2.ZERO
	player.set_collision_mask_value(3, true)

func _on_animation_finished():
	if animated_sprite and animated_sprite.animation.begins_with("jump_"):
		jump_completed = true

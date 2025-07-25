# Walk.gd
extends State
class_name PlayerWalk

var previous_input_dir = Vector2.ZERO

func Enter():
	animated_sprite = entity.animated_sprite
	
	var player = entity
	var input_dir = player.get_input_direction()
	previous_input_dir = input_dir

	Animate("walk", input_dir)

func Physics_Update(delta):
	var player = entity
	var input_dir = player.get_input_direction()
	
	if input_dir.length() == 0:
		Transitioned.emit(self, "idle")
		return

	if input_dir != previous_input_dir:
		Animate("walk", input_dir)
		previous_input_dir = input_dir
	
	player.velocity = input_dir * player.speed
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		
	if Input.is_action_just_pressed("melee"):
		Transitioned.emit(self, "melee")
		return

	if Input.is_action_just_pressed("cast"):
			Transitioned.emit(self, "cast")
			return
			

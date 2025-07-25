# Idle.gd
extends State
class_name PlayerIdle

func Enter():
	animated_sprite = entity.animated_sprite
	Animate("idle")

func Physics_Update(delta):
	var player = entity
	var input_dir = player.get_input_direction()
	
	if input_dir.length() > 0:
		Transitioned.emit(self, "walk")
		return
	
	player.velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")

	if Input.is_action_just_pressed("melee"):
		Transitioned.emit(self, "melee")
		return

	if Input.is_action_just_pressed("cast"):
			Transitioned.emit(self, "cast")
			return
			

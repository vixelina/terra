# State.gd
extends Node
class_name State

var entity: Node = null
var animated_sprite: AnimatedSprite2D = null

enum Direction { UP, DOWN, LEFT, RIGHT }

signal Transitioned(state, new_state_name)

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
	
func handle_input(_event: InputEvent): 
	pass

func Animate(state : String, input_direction : Vector2 = Vector2.ZERO):
	if !entity or !animated_sprite:
		return
	 
	if input_direction.length() > 0:
		if abs(input_direction.x) >= abs(input_direction.y):
			# horizontal direction
			if input_direction.x > 0:
				entity.current_direction = Direction.RIGHT
			else:
				entity.current_direction = Direction.LEFT
		else:
			# vertical direction
			if input_direction.y > 0:
				entity.current_direction = Direction.DOWN
			else:
				entity.current_direction = Direction.UP
	  
	var direction_str = ""
	var current_dir = entity.current_direction
	
	match current_dir:
		Direction.UP: direction_str = "up"
		Direction.DOWN: direction_str = "down"
		Direction.LEFT: direction_str = "left"
		Direction.RIGHT: direction_str = "right"
	 
	var animation_name = state + "_" + direction_str
	
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
	else:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(state):
			animated_sprite.play(state)

# Die.gd
extends State
class_name EntityDie

var death_animation_finished: bool = false

func Enter():
	animated_sprite = entity.animated_sprite
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation("die_down"):
		animated_sprite.play("die_down")
	
	if animated_sprite and !animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	death_animation_finished = false

func Physics_Update(delta):
	entity.velocity = Vector2.ZERO
	
	if death_animation_finished:
		Exit()

func _on_animation_finished():
	if animated_sprite and animated_sprite.animation == "die_down":
		death_animation_finished = true

func Exit():
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
		
	if entity.name != 'Player':
		entity.queue_free()
		print('Entity died!')
	else:
		print('Died!')

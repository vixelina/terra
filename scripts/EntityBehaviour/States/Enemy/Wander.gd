# Wander.gd
extends State
class_name EnemyWander

var move_direction : Vector2
var wander_time : float
var idle_time : float
var detection_range: float = 100.0

enum WanderState { MOVING, IDLE }
var current_wander_state = WanderState.MOVING

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3) * 10
	
func set_idle():
	current_wander_state = WanderState.IDLE
	idle_time = randf_range(1, 2)
	entity.velocity = Vector2.ZERO
	Animate("idle")
	
func set_moving():
	current_wander_state = WanderState.MOVING
	randomize_wander()
	Animate("walk", move_direction)
	
func Enter():
	animated_sprite = entity.get_node("AnimatedSprite2D") if entity.has_node("AnimatedSprite2D") else null
	detection_range = entity.get_detection_range()
	set_moving()

func Update(delta: float):
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var distance_to_player = entity.global_position.distance_to(player.global_position)
		if distance_to_player <= detection_range:
			Transitioned.emit(self, "chase")
			return
			
	match current_wander_state:
		WanderState.MOVING:
			if wander_time > 0:
				wander_time -= delta
			else:
				set_idle()
				
		WanderState.IDLE:
			if idle_time > 0:
				idle_time -= delta
			else:
				set_moving()
				
	if entity.is_hit:
		Transitioned.emit(self, "hit")
		
func Physics_Update(delta: float):
	var move_speed = entity.speed / 4
	if entity and current_wander_state == WanderState.MOVING:
		entity.velocity = move_direction * move_speed
		entity.move_and_slide()

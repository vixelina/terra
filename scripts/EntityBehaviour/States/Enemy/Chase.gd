# Chase.gd
extends State
class_name EnemyChase

var player: CharacterBody2D
var attack_range: float = 32.0
var detection_range: float = 100.0
var last_known_player_position: Vector2
var is_attacking: bool = false

func Enter():
	animated_sprite = entity.get_node("AnimatedSprite2D") if entity.has_node("AnimatedSprite2D") else null
	player = get_tree().get_first_node_in_group("Player")
	
	detection_range = entity.get_detection_range()
	attack_range = entity.get_attack_range()
	
	is_attacking = false
	
	if player:
		last_known_player_position = player.global_position

func Update(delta: float):
	if not player:
		Transitioned.emit(self, "wander")
		return
	
	var distance_to_player = entity.global_position.distance_to(player.global_position)

	if entity.is_hit:
		Transitioned.emit(self, "hit")
		return

	if distance_to_player <= attack_range:
		is_attacking = true
		Transitioned.emit(self, "attack")
		return
	
	if distance_to_player > detection_range:
		Transitioned.emit(self, "wander")
		return

	last_known_player_position = player.global_position

func Physics_Update(delta: float):
	if not player or not entity:
		return

	var direction = (player.global_position - entity.global_position).normalized()

	entity.velocity = direction * entity.speed
	entity.move_and_slide()

	Animate("walk", direction)

	if abs(direction.x) >= abs(direction.y):
		entity.current_direction = Entity.Direction.RIGHT if direction.x > 0 else Entity.Direction.LEFT
	else:
		entity.current_direction = Entity.Direction.DOWN if direction.y > 0 else Entity.Direction.UP

func Exit():
	if entity:
		entity.velocity = Vector2.ZERO
		is_attacking = false

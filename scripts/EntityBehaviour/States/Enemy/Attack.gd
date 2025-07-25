# Attack.gd
extends State
class_name EnemyAttack

var player: CharacterBody2D
var attack_range: float = 20.0
var detection_range: float = 100.0
var attack_completed: bool = false
var attack_cooldown: float = 2.0
var cooldown_timer: float = 0.0

func Enter():
	animated_sprite = entity.get_node("AnimatedSprite2D") if entity.has_node("AnimatedSprite2D") else null
	player = get_tree().get_first_node_in_group("Player")
	
	if entity is Monster:
		attack_range = entity.get_attack_range()
		detection_range = entity.get_detection_range()
	
	attack_completed = false
	cooldown_timer = 0.0
	
	entity.velocity = Vector2.ZERO
	
	if player:
		var direction = (player.global_position - entity.global_position).normalized()
		_start_attack(direction)

func _start_attack(direction: Vector2):
	if abs(direction.x) >= abs(direction.y):
		entity.current_direction = Entity.Direction.RIGHT if direction.x > 0 else Entity.Direction.LEFT
	else:
		entity.current_direction = Entity.Direction.DOWN if direction.y > 0 else Entity.Direction.UP
	
	var melee_weapon = entity.get_node_or_null("MeleeWeapon")
	melee_weapon.start_attack(direction, entity)

func Update(delta: float):
	cooldown_timer += delta
	
	if not player:
		Transitioned.emit(self, "wander")
		return
	
	var distance_to_player = entity.global_position.distance_to(player.global_position)
	
	if entity.is_hit:
		Transitioned.emit(self, "hit")
		return
	
	if cooldown_timer >= attack_cooldown:
		if distance_to_player <= attack_range:
			cooldown_timer = 0.0
			if player:
				var direction = (player.global_position - entity.global_position).normalized()
				_start_attack(direction)
		elif distance_to_player <= detection_range:
			Transitioned.emit(self, "chase")
		else:
			Transitioned.emit(self, "wander")

func Physics_Update(delta: float):
	entity.velocity = Vector2.ZERO

func Exit():
	if entity:
		entity.velocity = Vector2.ZERO
		cooldown_timer = 0.0

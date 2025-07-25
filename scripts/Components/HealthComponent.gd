# HealthComponent.gd
extends Node2D
class_name HealthComponent

@onready var health_bar: TextureProgressBar = $TextureProgressBar

@export var max_health := 100.0
var health : float

func _ready():
	if get_parent() is Entity:
		max_health = get_parent().health
		health = max_health
		update_health_bar()
		return
	
func damage(attack: Attack):
	var parent = get_parent()
	health -= attack.attack_damage
	health = max(0, health)
	print("[", get_parent().name,"] Took ", attack.attack_damage, " damage. Health: ", health, "/", max_health)
	update_health_bar()
	
	var state_machine = parent.get_node_or_null("State Machine")
	var current_state = state_machine.current_state
	
	if health <= 0:
		if get_parent().name != 'Player':
			health_bar.visible = false
		else:
			var interface = parent.get_node_or_null("Camera/Interface")
			if interface and interface.has_method("_show_death_screen"):
				interface._show_death_screen()
		current_state.Transitioned.emit(current_state, "die")
	else:
		current_state.Transitioned.emit(current_state, "hit")
		
func update_health_bar():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		
	if get_parent().name == "Player":
		health_bar.visible = true
	else:
		if health >= max_health:
			health_bar.visible = false
		else:
			health_bar.visible = true

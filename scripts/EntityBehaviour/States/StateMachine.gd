# StateMachine.gd
extends Node

@export var initial_state : State
var paused := false

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			var state_name = child.name.to_lower()
			states[state_name] = child
			child.entity = get_parent()
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state and not paused:
		current_state.Update(delta)
	
func _physics_process(delta):
	if current_state and not paused:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
	if state != current_state or paused:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	
	current_state = new_state
	

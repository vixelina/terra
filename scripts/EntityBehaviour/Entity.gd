# Entity.gd
extends CharacterBody2D
class_name Entity

# global variables -------------------------------------------------------------
@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var state_machine = $StateMachine if has_node("StateMachine") else null

@export var speed: float = 100.0
@export var health : float = 100.0
@export var is_hit := false

enum Direction { UP, DOWN, LEFT, RIGHT }
var current_direction = Direction.DOWN

# ------------------------------------------------------------------------------

func _ready():
	pass

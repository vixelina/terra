# Player.gd
extends Entity

var tile_size = Settings.tile_size
@onready var world: TileMap = $"../TileMap"

@onready var ranged_weapon = $RangedWeapon
@onready var melee_weapon = $MeleeWeapon

var is_jumping := false

var current_character_id: String = ""
var current_ranged_attacks: Array[RangedAttackData] = []
var current_ranged_index: int = 0

func _ready():
	super._ready()
	
func apply_character_data(character_data):
	if character_data == null:
		return
		
	print("Applying character: ", character_data.character_id)
	
	current_character_id = character_data.character_id
	
	animated_sprite.sprite_frames = character_data.character_sprite_frames
	
	var melee_sprite = melee_weapon.get_node("AnimatedSprite2D")
	melee_sprite.sprite_frames = character_data.melee_weapon_frames
	melee_weapon.attack_damage = character_data.melee_damage
	
	current_ranged_attacks = character_data.ranged_attacks
	current_ranged_index = character_data.default_ranged_index

func get_current_ranged_attack() -> RangedAttackData:
	if current_ranged_attacks.size() == 0:
		return null
	return current_ranged_attacks[current_ranged_index]

func is_magic_character() -> bool:
	return current_character_id == "mage"

func is_projectile_character() -> bool:
	return current_character_id == "rogue"

func next_ranged_attack():
	if current_ranged_attacks.size() > 1:
		current_ranged_index = (current_ranged_index + 1) % current_ranged_attacks.size()

func previous_ranged_attack():
	if current_ranged_attacks.size() > 1:
		current_ranged_index = (current_ranged_index - 1) % current_ranged_attacks.size()
				
func get_input_direction() -> Vector2:
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("move_left", "move_right")
	input_direction.y = Input.get_axis("move_up", "move_down")
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		
	return input_direction
	
func _unhandled_input(event):
	if state_machine and state_machine.current_state:
		state_machine.current_state.handle_input(event)

extends Node2D

# buttons ----------------------------------------------------------------------
@onready var start_button: TextureButton = $StartButton
@onready var resume_button: TextureButton = $ResumeButton
@onready var exit_button: TextureButton = $ExitButton
@onready var rogue_button: TextureButton = $RogueCharacter
@onready var mage_button: TextureButton = $MageCharacter

# save slot buttons and labels -------------------------------------------------
@onready var save0_button: TextureButton = $Save0
@onready var save1_button: TextureButton = $Save1
@onready var save2_button: TextureButton = $Save2

@onready var save0_label: Label = $Save0/Label
@onready var save1_label: Label = $Save1/Label
@onready var save2_label: Label = $Save2/Label

@onready var save0_icon: Sprite2D = $Save0/Sprite2D
@onready var save1_icon: Sprite2D = $Save1/Sprite2D
@onready var save2_icon: Sprite2D = $Save2/Sprite2D

# camera and UI ----------------------------------------------------------------
var original_camera_pos: Vector2
var save_buttons = []
var save_labels = []
var save_icons = []

# ------------------------------------------------------------------------------

func _ready() -> void:
	start_button.pressed.connect(on_start_pressed)
	resume_button.pressed.connect(on_resume_pressed)
	exit_button.pressed.connect(on_exit_pressed)
	rogue_button.pressed.connect(on_rogue_pressed)
	mage_button.pressed.connect(on_mage_pressed)
	
	save_buttons = [save0_button, save1_button, save2_button]
	save_labels = [save0_label, save1_label, save2_label]
	save_icons = [save0_icon, save1_icon, save2_icon]
	
	for i in range(save_buttons.size()):
		save_buttons[i].pressed.connect(_on_save_slot_pressed.bind(i))
	
	original_camera_pos = $Camera2D.position
	
	update_save_slots_labels()
	
# ------------------------------------------------------------------------------

func on_start_pressed() -> void:
	var screen_height = get_viewport().get_visible_rect().size.y
	var new_pos = $Camera2D.position + Vector2(0, screen_height)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "position", new_pos, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func on_resume_pressed() -> void:
	var screen_width = get_viewport().get_visible_rect().size.x
	var new_pos = $Camera2D.position - Vector2(screen_width, 0)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "position", new_pos, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func on_exit_pressed() -> void:
	SceneTransition.exit()

# ------------------------------------------------------------------------------

func on_rogue_pressed() -> void:
	new_game("rogue")

func on_mage_pressed() -> void:
	new_game("mage")

# ------------------------------------------------------------------------------

func new_game(character_id: String):
	var empty_slot = SaveManager.find_empty_slot()
	if empty_slot == -1:
		print("All save slots are occupied!")
		return

	var world_seed = int(Time.get_unix_time_from_system() * 1000)
	var slot_index = SaveManager.create_new_save(character_id, world_seed)
	
	if slot_index != -1:
		load_game_from_slot(slot_index)

# ------------------------------------------------------------------------------

func update_save_slots_labels():
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		var save_info = SaveManager.get_save_info(i)
		var icon_path = "res://resources/characters/%s/icon.tres" % save_info.character_id
		var icon_texture = load(icon_path)
		
		if save_info.exists:
			var time_text = SaveManager.format_time(save_info.playtime)
			save_labels[i].text = "Time: %s" % [time_text]
			save_buttons[i].disabled = false
			
			save_icons[i].texture = icon_texture
			save_icons[i].visible = true
		else:
			save_labels[i].text = "Empty Slot"
			save_buttons[i].disabled = true
			
			save_icons[i].visible = false

# ------------------------------------------------------------------------------
	
func _on_save_slot_pressed(slot_index: int):
	var save_info = SaveManager.get_save_info(slot_index)
	
	if save_info.exists:
		load_game_from_slot(slot_index)
	else:
		print("Empty slot clicked: ", slot_index)

# ------------------------------------------------------------------------------

func load_game_from_slot(slot_index: int):
	var save_game = SaveGame.load_savegame(slot_index)
	if save_game:
		var game_params = {
			"character_id": save_game.character_id,
			"world_seed": save_game.world_seed,
			"world_data": save_game.world_data,	
			"player_health": save_game.player_health,	
			"player_position": save_game.global_position,
			"load_slot": slot_index,
			"playtime": save_game.playtime
		}
		
		SceneTransition.change_scene("res://scenes/game.tscn", "dissolve", 1, game_params)
		
# ------------------------------------------------------------------------------
		
func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var tween = get_tree().create_tween()
		tween.tween_property($Camera2D, "position", original_camera_pos, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

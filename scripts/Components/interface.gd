# Interface.gd
extends Control

@onready var menu = $Menu
@onready var menu_button = $MenuButton
@onready var resume_button = $Menu/ResumeButton
@onready var save_button = $Menu/SaveButton
@onready var quit_button = $Menu/QuitButton
@onready var background_dim = $BackgroundDim
@onready var portal_label = $PortalTimerLabel
@onready var death_screen = $ResultScreen
@onready var victory_screen = $ResultScreen
@onready var result_label = $ResultScreen/Label
@onready var time_label = $ResultScreen/TimeLabel
@onready var back_to_title_button = $ResultScreen/BackToTitleButton
@onready var player_icon = $Menu/PlayerIcon/TextureRect
@onready var player_character = $Menu/PlayerCharacterLabel

var game_scene

var original_background_color: Color

# ------------------------------------------------------------------------------

func _ready():	
	menu_button.pressed.connect(_on_menu_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	back_to_title_button.pressed.connect(_on_back_to_title_button_pressed)
	
	menu.visible = false
	background_dim.visible = false
	death_screen.visible = false
	victory_screen.visible = false
	
	original_background_color = background_dim.color
	
	game_scene = get_node("../../../")
	
func _process(delta):
	var current_playtime = game_scene.get_current_playtime()
	var portal_activation_time = 600.0
	if current_playtime < portal_activation_time:
		var countdown = portal_activation_time - current_playtime
		var minutes = int(countdown) / 60
		var seconds = int(countdown) % 60
		portal_label.text = "%02d:%02d" % [minutes, seconds]
	else:
		var player = get_tree().get_first_node_in_group("Player")
		var distance = player.global_position.distance_to(Vector2i(0, 0))
		portal_label.text = "Escape! - %.0fm" % (distance / Settings.tile_size)
	
func _show_victory_screen():
	if victory_screen.visible:
		return
		
	result_label.text = "Victory!"
	var final_playtime = game_scene.get_current_playtime()
	var formatted_time = SaveManager.format_time(final_playtime)
	time_label.text = "Final Time: " + formatted_time
	
	background_dim.color = Color(0.0, 1.0, 0.0, 0.43)
	background_dim.visible = true
	victory_screen.visible = true
	get_tree().paused = true
	
func _show_death_screen():
	if death_screen.visible:
		return
		
	result_label.text = "You died!"
	var final_playtime = game_scene.get_current_playtime()
	var formatted_time = SaveManager.format_time(final_playtime)
	time_label.text = "Final Time: " + formatted_time
	
	background_dim.color = Color(1.0, 0.0, 0.0, 0.43)
	background_dim.visible = true
	death_screen.visible = true
	
func _on_back_to_title_button_pressed():
	if game_scene.current_save_slot >= 0:
		SaveGame.delete_save(game_scene.current_save_slot)
	
	get_tree().paused = false
	
	SceneTransition.change_scene("res://scenes/main_menu.tscn", "dissolve", 1, {})

# input handling ---------------------------------------------------------------
func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_menu()

# menu logic and data ----------------------------------------------------------
func toggle_menu():
	menu.visible = !menu.visible
	background_dim.visible = !background_dim.visible
	#get_tree().paused = !get_tree().paused
	
	if menu.visible:
		load_player_data()
	
func load_player_data():
	var character_id = game_scene.character_manager.selected_character_id
	var icon_path = "res://resources/characters/%s/icon.tres" % character_id
	player_icon.texture = load(icon_path)
	player_character.text = character_id.capitalize()

# button signal handlers -------------------------------------------------------
func _on_menu_button_pressed():
	toggle_menu()

func _on_resume_button_pressed():
	toggle_menu()
	
func _on_save_button_pressed():
	var game_scene = get_node("../../../")
	game_scene.save_game()
	print("Game saved!")
	
func _on_quit_button_pressed():
	game_scene.save_game()

	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/main_menu.tscn", "dissolve", 1, {})

# ------------------------------------------------------------------------------

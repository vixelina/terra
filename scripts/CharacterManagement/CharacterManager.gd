# CharacterManager.gd
extends Node

var characters = {}
var selected_character_id = ""

func _ready():
	load_characters()

func load_characters() -> void:
	var mage = load("res://scripts/characters/MageData.gd").new()
	var rogue = load("res://scripts/characters/RogueData.gd").new()
	
	characters[mage.character_id] = mage
	characters[rogue.character_id] = rogue

func select_character(character_id):
	selected_character_id = character_id
	print("Selected character: " + character_id)
	return true

func get_selected_character():
	return characters[selected_character_id]

func get_current_character_attack(attack_index):
	var character = get_selected_character()
	if character and character.ranged_attacks.size() > attack_index:
		return character.ranged_attacks[attack_index]
	return null

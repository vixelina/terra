# RogueData.gd
extends CharacterData

func _init():
	character_id = "rogue"
	character_sprite_frames = load("res://resources/characters/rogue/rogue.tres")
	health = 150.0
	
	melee_weapon_frames = load("res://resources/characters/rogue/melee.tres")
	melee_damage = 50.0
	
	var ranged = RangedAttackData.new()
	ranged.attack_id = "ranged"
	ranged.ranged_frames = load("res://resources/characters/rogue/ranged.tres")
	ranged.collision_shape = load("res://resources/characters/rogue/ranged_collision.tres")
	ranged.offset = Vector2(0, 0)
	ranged.damage = 10.0
	ranged.speed = 400.0
	ranged_attacks.append(ranged)

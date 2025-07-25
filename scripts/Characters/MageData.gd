# MageData.gd
extends CharacterData

func _init():
	character_id = "mage"
	character_sprite_frames = load("res://resources/characters/mage/mage.tres")
	health = 50.0
	
	melee_weapon_frames = load("res://resources/characters/mage/melee.tres")
	melee_damage = 10.0
	
	# 03
	var o3 = RangedAttackData.new()
	o3.attack_id = "default"
	o3.ranged_frames = load("res://resources/characters/mage/03.tres")
	o3.collision_shape = load("res://resources/characters/mage/03_collision.tres")
	o3.offset = Vector2(0, 0)
	o3.damage = 50.0
	o3.cooldown = 1.5
	ranged_attacks.append(o3)
	
	# 04
	var o4 = RangedAttackData.new()
	o4.attack_id = "up"
	o4.ranged_frames = load("res://resources/characters/mage/04.tres")
	o4.collision_shape = load("res://resources/characters/mage/04_collision.tres")
	o4.offset = Vector2(0, -24)
	o4.damage = 60.0
	ranged_attacks.append(o4)
	
	# 11
	var i1 = RangedAttackData.new()
	i1.attack_id = "down"
	i1.ranged_frames = load("res://resources/characters/mage/11.tres")
	i1.collision_shape = load("res://resources/characters/mage/11_collision.tres")
	i1.offset = Vector2(0, -28)
	i1.damage = 80.0
	ranged_attacks.append(i1)

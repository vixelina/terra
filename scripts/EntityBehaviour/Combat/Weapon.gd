# Weapon.gd
extends Area2D
class_name Weapon

@export var attack_damage := 10.0

static var stored_resources = {}

var is_active = false
var attacker = null

func _ready():
	if not area_entered.is_connected(_on_hitbox_area_entered):
		area_entered.connect(_on_hitbox_area_entered)
	
	if get_parent() is CharacterBody2D:
		_store_resources()
	
	_initialize_components()

func _store_resources():
	var weapon_type = get_class()
	
	var sprite_nodes = _find_sprite_nodes()
	for key in sprite_nodes:
		var node = sprite_nodes[key]
		if node:
			if node is Sprite2D and node.texture:
				stored_resources[weapon_type + "_" + key + "_texture"] = node.texture
			elif node is AnimatedSprite2D and node.sprite_frames:
				stored_resources[weapon_type + "_" + key + "_frames"] = node.sprite_frames

	var collision_nodes = _find_collision_nodes()
	for key in collision_nodes:
		var node = collision_nodes[key]
		if node:
			if node is CollisionShape2D and node.shape:
				if node.shape is CircleShape2D:
					stored_resources[weapon_type + "_" + key + "_radius"] = node.shape.radius
				elif node.shape is RectangleShape2D:
					stored_resources[weapon_type + "_" + key + "_extents"] = node.shape.extents
			elif node is CollisionPolygon2D:
				stored_resources[weapon_type + "_" + key + "_polygon"] = node.polygon

func _find_sprite_nodes() -> Dictionary:
	return {}

func _find_collision_nodes() -> Dictionary:
	return {}

func _initialize_components():
	pass

func _get_stored_resource(resource_type: String, resource_name: String):
	var weapon_type = get_class()
	var key = weapon_type + "_" + resource_name + "_" + resource_type
	
	if key in stored_resources:
		return stored_resources[key]
	return null

func _on_hitbox_area_entered(area):
	pass

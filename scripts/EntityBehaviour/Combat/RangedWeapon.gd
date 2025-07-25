# RangedWeapon.gd
extends Weapon
class_name ProjectileWeapon

# default weapon properties ----------------------------------------------------
@export var attack_speed: float = 400
@export var travel_distance: float = Settings.view_radius * Settings.tile_size
@export var impact_duration: float = 0.1
@export var knockback_force: float = 10.0
@export var loop_duration: float = 2.0

# weapon state variables -------------------------------------------------------
var weapon_type: String = "projectile"  # "projectile" or "magic"
var direction = Vector2.ZERO
var caster = null
var destination = Vector2.ZERO
var distance_traveled: float = 0

# node references --------------------------------------------------------------
var animated_sprite: AnimatedSprite2D = null
var collision_shape: CollisionShape2D = null

# ------------------------------------------------------------------------------

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not area_entered.is_connected(_on_hitbox_area_entered):
		area_entered.connect(_on_hitbox_area_entered)

	animated_sprite = get_node_or_null("AnimatedSprite2D")
	collision_shape = get_node_or_null("CollisionShape2D")

	animated_sprite.visible = false
	animated_sprite.animation_finished.connect(_on_animation_finished)
	collision_shape.disabled = true

# weapon initialization --------------------------------------------------------

func initialize_as_projectile(dir, dest, source_entity, attack_data: RangedAttackData):
	weapon_type = "projectile"
	direction = dir
	destination = dest
	caster = source_entity
	distance_traveled = 0
	
	_apply_attack_data(attack_data)

func initialize_as_magic(position: Vector2, source_entity, attack_data: RangedAttackData):
	weapon_type = "magic"
	global_position = position
	caster = source_entity
	
	_apply_attack_data(attack_data)

# ------------------------------------------------------------------------------

func _apply_attack_data(attack_data: RangedAttackData):
	attack_speed = attack_data.speed
	travel_distance = attack_data.travel_distance
	attack_damage = attack_data.damage
	knockback_force = attack_data.knockback

	animated_sprite.sprite_frames = attack_data.ranged_frames
	animated_sprite.offset = attack_data.offset
	collision_shape.shape = attack_data.collision_shape
	collision_shape.position = attack_data.offset

# ------------------------------------------------------------------------------

func start():
	animated_sprite.visible = true
	animated_sprite.play("start")

	if weapon_type == "projectile":
		collision_shape.disabled = false
		get_tree().create_timer(0.1).timeout.connect(_begin_movement)
	
	is_active = true

# projectile physics -----------------------------------------------------------

func _begin_movement():
	if weapon_type == "projectile":
		set_physics_process(true)

func _physics_process(delta):
	if !is_active or weapon_type != "projectile":
		return

# - projectile movement --------------------------------------------------------
	var previous_position = global_position
	global_position += direction * attack_speed * delta

	distance_traveled += previous_position.distance_to(global_position)
	if distance_traveled >= travel_distance:
		on_impact()
		return

	var to_destination = destination - global_position
	if to_destination.dot(direction) <= 10:
		on_impact()

# animations -------------------------------------------------------------------

func _on_animation_finished():
	if not is_active:
		return

	if weapon_type == "magic":
		match animated_sprite.animation:
			"start":
				_start_loop()
			"loop":
				_start_impact()
			"impact":
				_end_weapon()

	elif weapon_type == "projectile":
		if animated_sprite.animation == "impact":
			_end_weapon()

func _start_loop(): # magic
	animated_sprite.play("loop")
	collision_shape.disabled = false
	
	get_tree().create_timer(loop_duration).timeout.connect(_start_impact)

func _start_impact(): # magic
	animated_sprite.play("impact")
	collision_shape.disabled = true

func on_impact(): # projectile
	set_physics_process(false)

	animated_sprite.play("impact")
	collision_shape.disabled = true
	is_active = false

	get_tree().create_timer(impact_duration).timeout.connect(_end_weapon)

func _end_weapon(): # magic
	animated_sprite.visible = false
	collision_shape.disabled = true
	is_active = false

	queue_free()

# collision --------------------------------------------------------------------

func _on_hitbox_area_entered(area): # entity
	if !is_active:
		return

	var target = area.get_parent()
	if target == caster:
		return

	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.attack_position = global_position
		
# ------knockback direction ----------------------------------------------------
		if weapon_type == "magic":
			attack.knockback_direction = (target.global_position - global_position).normalized()
		else:
			attack.knockback_direction = direction
			
		attack.knockback_force = knockback_force
		attack.attack_type = weapon_type

		area.damage(attack)
		
		if weapon_type == "projectile":
			on_impact()

# ------------------------------------------------------------------------------

func _on_body_entered(body): # non entities with collision
	var monster_spawner = get_tree().get_first_node_in_group("MonsterSpawner")
	monster_spawner.tile_attack(global_position)
	
	if body == caster or !is_active or weapon_type == "magic":
		return
	
# - ignore weapon damage areas -------------------------------------------------
	var hitbox = body.get_node_or_null("HitboxComponent")
	if hitbox is HitboxComponent:
		return
	
	on_impact()

extends CharacterBody2D
class_name Player

@export var max_health: int = 100
@export var current_health: int = 100
@export var speed: float = 200.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

signal health_changed(new_health: int, max_health: int)
signal weapon_equipped(weapon: Weapon)
signal weapon_unequipped
signal player_died

var current_weapon: Weapon = null
var inventory: Array[Weapon] = []
var is_dashing: bool = false
var dash_timer: Timer
var dash_cooldown_timer: Timer
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var weapon_position: Node2D = $WeaponPosition

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)
	add_to_group("player")

	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_finished)

	dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true

func _on_dash_finished():
	is_dashing = false

func _physics_process(delta):
	if current_health <= 0:
		return

	_handle_knockback(delta)
	_handle_input()
	_handle_movement(delta)
	_handle_weapon_rotation()

	move_and_slide()

func _handle_knockback(delta):
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)

func _handle_input():
	if Input.is_action_just_pressed("attack"):
		_attack()

	if Input.is_action_just_pressed("heavy_attack"):
		_heavy_attack()

	if Input.is_action_just_pressed("reload"):
		_reload()

	if Input.is_action_just_pressed("dash"):
		_dash()

	if Input.is_action_just_pressed("switch_weapon"):
		_switch_weapon()

	if Input.is_action_just_pressed("drop_weapon"):
		_drop_weapon()

func _handle_movement(delta):
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if is_dashing:
		velocity = velocity.normalized() * dash_speed
		velocity += knockback_velocity
		return

	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	velocity += knockback_velocity

func _handle_weapon_rotation():
	if weapon_position and current_weapon:
		var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - global_position).normalized()

		var orbit_radius = 50.0
		var weapon_orbit_position = direction * orbit_radius
		weapon_position.position = weapon_orbit_position

		weapon_position.rotation = direction.angle()

		if direction.x < 0:
			weapon_position.scale.y = -1
		else:
			weapon_position.scale.y = 1

func _attack():
	if current_weapon:
		var mouse_position = get_global_mouse_position()
		current_weapon.use_weapon(mouse_position)

func _heavy_attack():
	if current_weapon and current_weapon is WeaponMelee:
		var mouse_position = get_global_mouse_position()
		(current_weapon as WeaponMelee).heavy_attack(mouse_position)

func _reload():
	if current_weapon and current_weapon is WeaponRanged:
		(current_weapon as WeaponRanged).reload()

func _dash():
	if _can_dash():
		is_dashing = true
		dash_timer.start()
		dash_cooldown_timer.start()

func _can_dash() -> bool:
	return dash_cooldown_timer.is_stopped()

func _switch_weapon():
	if inventory.size() > 1:
		var current_index = inventory.find(current_weapon)
		var next_index = (current_index + 1) % inventory.size()
		equip_weapon(inventory[next_index])

func equip_weapon(weapon: Weapon):
	if current_weapon:
		unequip_weapon()

	current_weapon = weapon
	weapon_position.add_child(weapon)
	weapon.position = Vector2.ZERO
	weapon_equipped.emit(weapon)

func unequip_weapon():
	if current_weapon:
		weapon_position.remove_child(current_weapon)
		current_weapon = null
		weapon_unequipped.emit()

func add_weapon_to_inventory(weapon: Weapon):
	inventory.append(weapon)
	if not current_weapon:
		equip_weapon(weapon)
	print("Picked up: ", weapon.weapon_name)

func remove_weapon_from_inventory(weapon: Weapon):
	if weapon == current_weapon:
		unequip_weapon()
	inventory.erase(weapon)

func _drop_weapon():
	if current_weapon and inventory.size() > 0:
		var dropped_weapon = current_weapon
		var weapon_pickup_scene = preload("res://Scenes/WeaponPickup.tscn")

		if weapon_pickup_scene:
			var pickup = weapon_pickup_scene.instantiate()
			get_tree().current_scene.add_child(pickup)
			pickup.global_position = global_position + Vector2(50, 0)

			if dropped_weapon.weapon_scene_path != "":
				pickup.weapon_scene = load(dropped_weapon.weapon_scene_path)

			remove_weapon_from_inventory(dropped_weapon)

			if inventory.size() > 0:
				equip_weapon(inventory[0])
		else:
			print("WeaponPickup scene not found!")

func take_damage(amount: int):
	if current_health <= 0:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func apply_knockback(force: Vector2):
	knockback_velocity += force * 0.7

func _die():
	player_died.emit()
	set_physics_process(false)

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

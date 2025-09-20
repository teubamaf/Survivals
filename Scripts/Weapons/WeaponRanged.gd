extends Weapon
class_name WeaponRanged

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var ammunition: int = 30
@export var max_ammunition: int = 30
@export var reload_time: float = 2.0
@export var bullet_spread: float = 5.0
@export var burst_count: int = 1
@export var burst_delay: float = 0.1

signal ammunition_empty
signal reload_started
signal reload_finished

var is_reloading: bool = false
var reload_timer: Timer

func can_attack() -> bool:
	return super.can_attack() and ammunition > 0 and not is_reloading

func _ready():
	super._ready()
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_finished)

func can_reload() -> bool:
	return not is_reloading and ammunition < max_ammunition

func reload() -> bool:
	if not can_reload():
		return false

	is_reloading = true
	reload_started.emit()
	reload_timer.start()
	return true

func _on_reload_finished():
	ammunition = max_ammunition
	is_reloading = false
	reload_finished.emit()

func _perform_attack(target_position: Vector2):
	if not projectile_scene:
		print("Warning: No projectile scene assigned to ", weapon_name)
		return

	for i in range(burst_count):
		_fire_projectile(target_position)
		ammunition -= 1

		if ammunition <= 0:
			ammunition_empty.emit()
			break

		if burst_count > 1 and i < burst_count - 1:
			await get_tree().create_timer(burst_delay).timeout

func _fire_projectile(target_position: Vector2):
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position

	var direction = (target_position - global_position).normalized()

	var spread_angle = deg_to_rad(randf_range(-bullet_spread, bullet_spread))
	direction = direction.rotated(spread_angle)

	projectile.rotation = direction.angle()

	if projectile.has_method("set_velocity"):
		projectile.set_velocity(direction * projectile_speed)
	elif projectile.has_method("set_direction"):
		projectile.set_direction(direction)
		projectile.set_speed(projectile_speed)

	if projectile.has_method("set_damage"):
		projectile.set_damage(get_attack_damage())

	if projectile.has_method("set_owner_node"):
		projectile.set_owner_node(get_parent())

func get_ammunition_percent() -> float:
	return float(ammunition) / float(max_ammunition)
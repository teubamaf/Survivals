extends Weapon
class_name WeaponMelee

@export var swing_arc: float = 90.0
@export var knockback_force: float = 200.0
@export var heavy_attack_multiplier: float = 1.5
@export var heavy_attack_cooldown: float = 2.0

var heavy_attack_timer: Timer

func _ready():
	super._ready()
	attack_speed = 2.0
	attack_timer.wait_time = 0.5

	heavy_attack_timer = Timer.new()
	add_child(heavy_attack_timer)
	heavy_attack_timer.wait_time = heavy_attack_cooldown
	heavy_attack_timer.one_shot = true

func can_heavy_attack() -> bool:
	return heavy_attack_timer.is_stopped() and can_attack()

func heavy_attack(target_position: Vector2) -> bool:
	if not can_heavy_attack():
		return false

	is_attacking = true
	heavy_attack_timer.start()
	attack_timer.start()

	_perform_heavy_attack(target_position)
	_consume_durability(2)

	weapon_used.emit()
	is_attacking = false
	return true

func _perform_attack(target_position: Vector2):
	var attack_area = await _get_attack_area()
	var bodies = attack_area.get_overlapping_bodies()

	for body in bodies:
		if body.has_method("take_damage") and body != get_parent():
			var direction = (body.global_position - global_position).normalized()
			body.take_damage(get_attack_damage())
			if body.has_method("apply_knockback"):
				body.apply_knockback(direction * knockback_force * 0.5)

func _perform_heavy_attack(target_position: Vector2):
	var attack_area = await _get_attack_area()
	var bodies = attack_area.get_overlapping_bodies()

	for body in bodies:
		if body.has_method("take_damage") and body != get_parent():
			var direction = (body.global_position - global_position).normalized()
			var heavy_damage = int(get_attack_damage() * heavy_attack_multiplier)
			body.take_damage(heavy_damage)
			if body.has_method("apply_knockback"):
				body.apply_knockback(direction * knockback_force)

func _get_attack_area() -> Area2D:
	# Utilise l'Area2D de la scène si disponible, sinon crée une temporaire
	if self is Area2D:
		return self as Area2D
	else:
		var area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		var shape = CircleShape2D.new()

		shape.radius = range
		collision_shape.shape = shape
		area.add_child(collision_shape)

		get_tree().current_scene.add_child(area)
		area.global_position = global_position

		await get_tree().process_frame
		area.queue_free()

		return area

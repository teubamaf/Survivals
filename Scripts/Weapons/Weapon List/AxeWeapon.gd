extends WeaponMelee
class_name AxeWeapon

var original_rotation: float
var is_swinging: bool = false

func _ready():
	super._ready()
	weapon_name = "Battle Axe"
	damage = 35
	attack_speed = 1.5
	range = 80.0
	durability = 150
	max_durability = 150
	swing_arc = 120.0
	knockback_force = 300.0
	heavy_attack_multiplier = 2.0
	heavy_attack_cooldown = 3.0

	attack_timer.wait_time = 0.7

func _perform_attack(target_position: Vector2):
	_perform_swing_effect()
	super._perform_attack(target_position)

func _perform_heavy_attack(target_position: Vector2):
	_perform_heavy_swing_effect()
	super._perform_heavy_attack(target_position)

func _perform_swing_effect():
	if is_swinging:
		return

	is_swinging = true
	original_rotation = rotation

	var swing_tween = create_tween()

	# Phase 1: Préparation du swing
	swing_tween.parallel().tween_property(self, "rotation", original_rotation - deg_to_rad(swing_arc/2), 0.1)
	swing_tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)

	# Phase 2: Swing principal
	swing_tween.tween_property(self, "rotation", original_rotation + deg_to_rad(swing_arc/2), 0.2)

	# Phase 3: Retour à la position normale
	swing_tween.parallel().tween_property(self, "rotation", original_rotation, 0.1)
	swing_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	swing_tween.tween_callback(func(): is_swinging = false)

func _perform_heavy_swing_effect():
	if is_swinging:
		return

	is_swinging = true
	original_rotation = rotation

	var heavy_swing_tween = create_tween()

	# Phase 1: Préparation du heavy swing
	heavy_swing_tween.parallel().tween_property(self, "rotation", original_rotation - deg_to_rad(swing_arc), 0.15)
	heavy_swing_tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)

	# Phase 2: Heavy swing principal
	heavy_swing_tween.tween_property(self, "rotation", original_rotation + deg_to_rad(swing_arc), 0.3)

	# Phase 3: Retour à la position normale
	heavy_swing_tween.parallel().tween_property(self, "rotation", original_rotation, 0.15)
	heavy_swing_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

	heavy_swing_tween.tween_callback(func(): is_swinging = false)

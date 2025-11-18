extends WeaponMelee
class_name PickaxeWeapon

@onready var swing_sound: AudioStreamPlayer2D = $SwingSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var original_rotation: float
var is_swinging: bool = false

func _ready():
	super._ready()
	weapon_name = "Stone Pickaxe"
	damage = 50
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

	# Appeler l'attaque parente et vérifier si on a touché quelque chose
	var attack_area = await _get_attack_area()
	var bodies = attack_area.get_overlapping_bodies()

	var hit_something = false
	for body in bodies:
		if body.has_method("take_damage") and body != get_parent():
			var direction = (body.global_position - global_position).normalized()
			body.take_damage(get_attack_damage())
			if body.has_method("apply_knockback"):
				body.apply_knockback(direction * knockback_force * 0.5)
			hit_something = true

	# Jouer le son de hit si on a touché quelque chose
	if hit_something and hit_sound:
		hit_sound.pitch_scale = randf_range(0.95, 1.05)
		hit_sound.play()

func _perform_heavy_attack(target_position: Vector2):
	_perform_heavy_swing_effect()

	# Appeler l'attaque parente et vérifier si on a touché quelque chose
	var attack_area = await _get_attack_area()
	var bodies = attack_area.get_overlapping_bodies()

	var hit_something = false
	for body in bodies:
		if body.has_method("take_damage") and body != get_parent():
			var direction = (body.global_position - global_position).normalized()
			var heavy_damage = int(get_attack_damage() * heavy_attack_multiplier)
			body.take_damage(heavy_damage)
			if body.has_method("apply_knockback"):
				body.apply_knockback(direction * knockback_force)
			hit_something = true

	# Jouer le son de hit si on a touché quelque chose (plus grave pour heavy)
	if hit_something and hit_sound:
		hit_sound.pitch_scale = randf_range(0.85, 0.95)  # Plus grave
		hit_sound.play()

func _perform_swing_effect():
	if is_swinging:
		return

	is_swinging = true
	original_rotation = 0.0  
	rotation = 0.0  #

	# Jouer le son de swing
	if swing_sound:
		swing_sound.pitch_scale = randf_range(0.9, 1.1)  # Variation aléatoire
		swing_sound.play()

	var swing_tween = create_tween()

	# Phase 1: Préparation du swing
	swing_tween.parallel().tween_property(self, "rotation", -deg_to_rad(swing_arc/2), 0.1)
	swing_tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)

	# Phase 2: Swing principal
	swing_tween.tween_property(self, "rotation", deg_to_rad(swing_arc/2), 0.2)

	# Phase 3: Retour à la position normale
	swing_tween.parallel().tween_property(self, "rotation", 0.0, 0.1)
	swing_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	swing_tween.tween_callback(func():
		rotation = 0.0  # Force le retour à 0
		is_swinging = false
	)

func _perform_heavy_swing_effect():
	if is_swinging:
		return

	is_swinging = true
	original_rotation = 0.0 
	rotation = 0.0 

	# Jouer le son de swing 
	if swing_sound:
		swing_sound.pitch_scale = randf_range(0.75, 0.85)  
		swing_sound.play()

	var heavy_swing_tween = create_tween()

	# Phase 1: Préparation du heavy swing
	heavy_swing_tween.parallel().tween_property(self, "rotation", -deg_to_rad(swing_arc), 0.15)
	heavy_swing_tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)

	# Phase 2: Heavy swing principal
	heavy_swing_tween.tween_property(self, "rotation", deg_to_rad(swing_arc), 0.3)

	# Phase 3: Retour à la position normale
	heavy_swing_tween.parallel().tween_property(self, "rotation", 0.0, 0.15)
	heavy_swing_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

	heavy_swing_tween.tween_callback(func():
		rotation = 0.0  # Force le retour à 0
		is_swinging = false
	)

extends WeaponRanged
class_name AssaultRifleWeapon

@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound
@onready var empty_sound: AudioStreamPlayer2D = $EmptySound

func _ready():
	super._ready()

	# Configuration du fusil d'assaut
	weapon_name = "Assault Rifle"
	damage = 20  
	attack_speed = 8.0  
	ammunition = 30  
	max_ammunition = 30
	range = 600.0  
	durability = 200
	max_durability = 200

	# Configuration spécifique projectile
	projectile_speed = 1200.0 

	
	if attack_timer:
		attack_timer.wait_time = 1.0 / attack_speed

func _fire_projectile(target_position: Vector2):
	# Appeler la fonction parente pour créer le projectile
	super._fire_projectile(target_position)


	if shoot_sound:
		shoot_sound.pitch_scale = randf_range(0.95, 1.05)
		shoot_sound.play()


	_apply_recoil_effect()

func reload() -> bool:
	var success = super.reload()

	if success and reload_sound:
		reload_sound.play()

	return success

func use_weapon(target_position: Vector2 = Vector2.ZERO) -> bool:
	# Si plus de munitions, jouer le son de clic à vide
	if ammunition <= 0 and empty_sound:
		empty_sound.play()
		return false

	return super.use_weapon(target_position)

func _apply_recoil_effect():
	#effet de recul visuel sur le sprite
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "position:x", -3, 0.05)
		tween.tween_property(sprite, "position:x", 0, 0.05)

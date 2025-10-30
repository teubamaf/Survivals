extends WeaponRanged
class_name PistolWeapon

@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound

func _ready():
	super._ready()
	weapon_name = "Pistol"
	damage = 25
	attack_speed = 5.0  # Tir plus rapide (était 3.0)
	range = 300.0
	durability = 100
	max_durability = 100
	projectile_speed = 600.0
	ammunition = 8  # 8 balles au lieu de 12
	max_ammunition = 8
	reload_time = 1.5
	bullet_spread = 3.0
	burst_count = 1


func _fire_projectile(target_position: Vector2):
	super._fire_projectile(target_position)
	if shoot_sound:
		shoot_sound.pitch_scale = randf_range(0.95, 1.05)
		shoot_sound.play()

func reload() -> bool:
	var success = super.reload()

	if success and reload_sound:
		reload_sound.play()

	return success

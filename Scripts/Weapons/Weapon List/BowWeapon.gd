extends WeaponRanged
class_name Bow


@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound

func _ready():
	super._ready()
	weapon_name = "Bow"
	damage = 25
	attack_speed = 5.0  
	range = 300.0
	durability = 100
	max_durability = 100
	projectile_speed = 600.0
	ammunition = 1  
	max_ammunition = 8
	reload_time = 0.8
	bullet_spread = 1
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

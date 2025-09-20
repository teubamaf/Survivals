extends WeaponRanged
class_name PistolWeapon

func _ready():
	super._ready()
	weapon_name = "Pistol"
	damage = 25
	attack_speed = 3.0
	range = 300.0
	durability = 100
	max_durability = 100
	projectile_speed = 600.0
	ammunition = 12
	max_ammunition = 12
	reload_time = 1.5
	bullet_spread = 3.0
	burst_count = 1

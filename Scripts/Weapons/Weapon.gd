extends Area2D
class_name Weapon

@export var weapon_name: String = "Basic Weapon"
@export var weapon_scene_path: String = ""
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var range: float = 100.0
@export var durability: int = 100
@export var max_durability: int = 100

signal weapon_used
signal weapon_broken

var is_attacking: bool = false
var attack_timer: Timer

func _ready():
	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.one_shot = true

func can_attack() -> bool:
	return attack_timer.is_stopped() and durability > 0

func use_weapon(target_position: Vector2 = Vector2.ZERO) -> bool:
	if not can_attack():
		return false

	is_attacking = true
	attack_timer.start()

	_perform_attack(target_position)
	_consume_durability()

	weapon_used.emit()
	is_attacking = false
	return true

func _perform_attack(target_position: Vector2):
	pass

func _consume_durability(amount: int = 1):
	durability = max(0, durability - amount)
	if durability <= 0:
		weapon_broken.emit()

func repair(amount: int):
	durability = min(max_durability, durability + amount)

func get_attack_damage() -> int:
	var durability_modifier = float(durability) / float(max_durability)
	return int(damage * durability_modifier)

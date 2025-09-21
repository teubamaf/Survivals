extends Enemy
class_name Zombie

@export var infection_damage: int = 5
@export var infection_chance: float = 0.3
@export var lunge_force: float = 300.0
@export var lunge_cooldown: float = 3.0
@export var gore_effects: bool = true

signal zombie_lunged
signal infection_applied(target: Node2D)

var lunge_timer: Timer
var is_lunging: bool = false
var lunge_target: Vector2

func _ready():
	max_health = 100
	current_health = max_health
	speed = 100.0
	damage = 25
	attack_range = 60.0
	detection_range = 250.0
	attack_cooldown = 1.5
	knockback_resistance = 0.3
	super._ready()

	lunge_timer = Timer.new()
	add_child(lunge_timer)
	lunge_timer.wait_time = lunge_cooldown
	lunge_timer.one_shot = true

func _handle_combat():
	super._handle_combat()

	if state == EnemyState.CHASING and target and _can_lunge():
		_perform_lunge()

func _can_lunge() -> bool:
	return lunge_timer.is_stopped() and target and _distance_to(target) > attack_range * 1.5

func _perform_lunge():
	lunge_timer.start()
	is_lunging = true
	lunge_target = target.global_position

	var direction = (lunge_target - global_position).normalized()
	apply_knockback(direction * lunge_force)

	zombie_lunged.emit()

	await get_tree().create_timer(0.5).timeout
	is_lunging = false

func _perform_attack():
	super._perform_attack()

	if target and randf() <= infection_chance:
		_apply_infection()

func _apply_infection():
	if target and target.has_method("take_damage"):
		target.take_damage(infection_damage)
		infection_applied.emit(target)

		if target.has_method("apply_status_effect"):
			target.apply_status_effect("infection", 5.0)

func _on_damage_taken(amount: int):
	if gore_effects:
		_spawn_blood_effect()

func _spawn_blood_effect():
	pass



func _die():
	super._die()
	if gore_effects:
		_spawn_death_effect()

func _spawn_death_effect():
	pass

extends CharacterBody2D
class_name Enemy

enum EnemyState {
	IDLE,
	CHASING,
	ATTACKING,
	STUNNED,
	DYING
}

@export var max_health: int = 100
@export var current_health: int
@export var speed: float = 100.0
@export var damage: int = 10
@export var attack_range: float = 50.0
@export var detection_range: float = 200.0
@export var attack_cooldown: float = 1.0
@export var knockback_resistance: float = 0.5
@export var xp_reward: int = 10

var state: EnemyState = EnemyState.IDLE
var target: Node2D
var attack_timer: Timer
var last_attack_time: float = 0.0

signal enemy_died(enemy: Enemy)
signal health_changed(current: int, max: int)
signal damage_taken(amount: int)

func _ready():
	if current_health <= 0:
		current_health = max_health

	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true

	add_to_group("enemies")

func _physics_process(delta):
	if state == EnemyState.DYING:
		return

	_update_target()
	_handle_state_machine()
	_handle_movement(delta)
	_handle_combat()

func _update_target():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var closest_player = players[0]
		var closest_distance = _distance_to(closest_player)

		for player in players:
			var distance = _distance_to(player)
			if distance < closest_distance:
				closest_player = player
				closest_distance = distance

		if closest_distance <= detection_range:
			target = closest_player
		elif closest_distance > detection_range * 1.5:
			target = null

func _handle_state_machine():
	match state:
		EnemyState.IDLE:
			if target:
				state = EnemyState.CHASING

		EnemyState.CHASING:
			if not target:
				state = EnemyState.IDLE
			elif target and _distance_to(target) <= attack_range:
				state = EnemyState.ATTACKING

		EnemyState.ATTACKING:
			if not target or _distance_to(target) > attack_range * 1.2:
				state = EnemyState.CHASING

func _handle_movement(delta):
	if state != EnemyState.CHASING or not target:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 2 * delta)
		move_and_slide()
		return

	var direction = (target.global_position - global_position).normalized()

	# Si trop proche du joueur, recule légèrement pour éviter le blocage
	var distance_to_target = _distance_to(target)
	if distance_to_target < 30.0:  # Distance très proche
		direction *= -0.3  # Recule légèrement
		velocity = velocity.move_toward(direction * speed * 0.5, speed * 2 * delta)
	else:
		velocity = velocity.move_toward(direction * speed, speed * 3 * delta)

	move_and_slide()

func _handle_combat():
	if state == EnemyState.ATTACKING and target and attack_timer.is_stopped():
		_perform_attack()

func _perform_attack():
	if not target or _distance_to(target) > attack_range:
		return

	attack_timer.start()

	if target.has_method("take_damage"):
		target.take_damage(damage)

func take_damage(amount: int):
	current_health = max(0, current_health - amount)

	# Effet visuel de dégât
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	damage_taken.emit(amount)
	health_changed.emit(current_health, max_health)

	# Appel de la méthode virtuelle pour les sous-classes
	_on_damage_taken(amount)

	if current_health <= 0:
		_die()

func apply_knockback(force: Vector2):
	var knockback_force = force * (1.0 - knockback_resistance)
	velocity += knockback_force

func _distance_to(node: Node2D) -> float:
	if not node:
		return INF
	return global_position.distance_to(node.global_position)

# Méthodes virtuelles pour les sous-classes
func _on_damage_taken(amount: int):
	pass

func _die():
	state = EnemyState.DYING

	# Donner de l'XP au joueur
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("gain_xp"):
		players[0].gain_xp(xp_reward)

	enemy_died.emit(self)

	# Effet de mort
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

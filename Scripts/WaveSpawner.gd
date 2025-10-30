extends Node2D
class_name WaveSpawner

## Système de spawn de vagues de monstres
## Vagues toutes les 5 minutes

@export var zombie_scene: PackedScene
@export var calm_duration: float = 10.0#300.0  # 5 minutes en secondes
@export var wave_duration: float = 60.0  # 1 minute de vague
@export var spawn_radius_min: float = 400.0  # Distance minimale du joueur
@export var spawn_radius_max: float = 600.0  # Distance maximale du joueur

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal calm_period_started

var current_wave: int = 0
var is_wave_active: bool = false
var player: Player = null

var calm_timer: Timer
var wave_timer: Timer
var spawn_timer: Timer

func _ready():
	# Trouver le joueur
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if not player:
		print("❌ WaveSpawner: Joueur non trouvé!")
		return

	# Timer pour la période calme
	calm_timer = Timer.new()
	calm_timer.one_shot = true
	calm_timer.timeout.connect(_start_wave)
	add_child(calm_timer)

	# Timer pour la durée de la vague
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_end_wave)
	add_child(wave_timer)

	# Timer pour spawn régulier pendant la vague
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_spawn_zombie)
	add_child(spawn_timer)

	# Démarrer la première période calme
	_start_calm_period()
	print("✓ WaveSpawner initialisé - Première vague dans", calm_duration, "secondes")

func _start_calm_period():
	is_wave_active = false
	spawn_timer.stop()
	calm_timer.start(calm_duration)
	calm_period_started.emit()
	print("--- Période calme ---")
	print("Prochaine vague dans", calm_duration, "secondes")

func _start_wave():
	current_wave += 1
	is_wave_active = true
	wave_started.emit(current_wave)

	print("\n=== VAGUE", current_wave, "COMMENCE ===")
	print("Durée:", wave_duration, "secondes")

	# Calculer combien de zombies spawner
	var zombies_to_spawn = _calculate_zombie_count()
	var spawn_interval = wave_duration / float(zombies_to_spawn)

	print("Zombies à spawner:", zombies_to_spawn)
	print("Intervalle de spawn:", spawn_interval, "secondes")

	# Démarrer le spawn régulier
	spawn_timer.start(spawn_interval)

	# Démarrer le timer de fin de vague
	wave_timer.start(wave_duration)

func _end_wave():
	is_wave_active = false
	spawn_timer.stop()
	wave_ended.emit(current_wave)

	print("=== VAGUE", current_wave, "TERMINÉE ===\n")

	# Recommencer une période calme
	_start_calm_period()

func _calculate_zombie_count() -> int:
	# Augmente le nombre de zombies à chaque vague
	var base_count = 5
	var per_wave_increase = 3
	return base_count + (current_wave - 1) * per_wave_increase

func _spawn_zombie():
	if not zombie_scene or not player:
		return

	# Position aléatoire autour du joueur
	var spawn_pos = _get_random_spawn_position()

	# Créer le zombie
	var zombie = zombie_scene.instantiate()
	get_tree().current_scene.add_child(zombie)
	zombie.global_position = spawn_pos

	# Forcer le zombie à cibler le joueur immédiatement
	# Les zombies utilisent déjà _update_target() mais on force pour être sûr
	if zombie.has_method("set_target"):
		zombie.set_target(player)
	elif "target" in zombie:
		zombie.target = player
		# Forcer l'état CHASING pour qu'il commence immédiatement à poursuivre
		if "state" in zombie:
			zombie.state = 1  # EnemyState.CHASING = 1

	print("  → Zombie spawné à", spawn_pos, "et cible le joueur")

func _get_random_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO

	# Angle aléatoire
	var angle = randf() * TAU

	# Distance aléatoire entre min et max
	var distance = randf_range(spawn_radius_min, spawn_radius_max)

	# Position finale
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return player.global_position + offset

func get_time_until_next_wave() -> float:
	if is_wave_active:
		return 0.0
	return calm_timer.time_left

func get_wave_time_remaining() -> float:
	if not is_wave_active:
		return 0.0
	return wave_timer.time_left

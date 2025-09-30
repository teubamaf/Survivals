extends StaticBody2D
class_name Trees

@export var max_health: int = 100
@export var min_logs_drop: int = 2
@export var max_logs_drop: int = 5
@export var hit_shake_intensity: float = 5.0
@export var hit_shake_duration: float = 0.2

var current_health: int
var tree_log_scene = preload("res://Scenes/Ressources/Drops/Tree_log.tscn")
var original_position: Vector2
var is_shaking: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	current_health = max_health
	original_position = sprite.position
	add_to_group("harvestable")

func take_damage(amount: int):
	current_health -= amount
	_play_hit_effect()

	if current_health <= 0:
		_destroy_tree()

func _play_hit_effect():
	if is_shaking:
		return

	is_shaking = true
	var tween = create_tween()

	# Animation de secousse
	for i in range(4):
		var shake_offset = Vector2(randf_range(-hit_shake_intensity, hit_shake_intensity),
									randf_range(-hit_shake_intensity, hit_shake_intensity))
		tween.tween_property(sprite, "position", original_position + shake_offset, hit_shake_duration / 8)

	# Retour à la position originale
	tween.tween_property(sprite, "position", original_position, hit_shake_duration / 4)
	tween.finished.connect(func(): is_shaking = false)

	# Flash blanc
	tween.parallel().tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _destroy_tree():
	_spawn_logs()
	queue_free()

func _spawn_logs():
	var log_count = randi_range(min_logs_drop, max_logs_drop)

	var log_drop = tree_log_scene.instantiate()
	get_parent().add_child(log_drop)
	log_drop.global_position = global_position
	log_drop.set_log_amount(log_count)

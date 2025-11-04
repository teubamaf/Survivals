extends Control
class_name WaveDisplay

## Affichage des informations de vague en haut au centre

@onready var wave_label: Label = $Panel/MarginContainer/VBoxContainer/WaveLabel
@onready var timer_label: Label = $Panel/MarginContainer/VBoxContainer/TimerLabel
@onready var status_label: Label = $Panel/MarginContainer/VBoxContainer/StatusLabel

var wave_spawner: WaveSpawner = null

func _ready():
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_left = 0
	offset_top = 20
	offset_right = 0
	offset_bottom = 120

	await get_tree().process_frame
	wave_spawner = get_tree().get_first_node_in_group("wave_spawner")

	if wave_spawner:
		wave_spawner.wave_started.connect(_on_wave_started)
		wave_spawner.wave_ended.connect(_on_wave_ended)
		wave_spawner.calm_period_started.connect(_on_calm_period_started)
		print("✓ WaveDisplay connecté au WaveSpawner")
	else:
		print("❌ WaveDisplay: WaveSpawner non trouvé")

func _process(_delta):
	if not wave_spawner:
		return

	# Mettre à jour le timer
	if wave_spawner.is_wave_active:
		var time_left = wave_spawner.get_wave_time_remaining()
		timer_label.text = "Temps restant: " + _format_time(time_left)
		timer_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))  # Rouge
	else:
		var time_until = wave_spawner.get_time_until_next_wave()
		timer_label.text = "Prochaine vague dans: " + _format_time(time_until)
		timer_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))  # Vert

func _on_wave_started(wave_number: int):
	wave_label.text = "VAGUE " + str(wave_number)
	status_label.text = "⚠️ EN COURS"
	status_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))

	# Animation d'apparition
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)

func _on_wave_ended(wave_number: int):
	status_label.text = "✓ TERMINÉE"
	status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))

func _on_calm_period_started():
	status_label.text = "PÉRIODE CALME"
	status_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1))

func _format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%d:%02d" % [minutes, secs]

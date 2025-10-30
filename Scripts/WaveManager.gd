extends Node

## Manager pour le système de vagues
## Instancie le WaveSpawner et le WaveDisplay

@export var zombie_scene: PackedScene

var wave_spawner = null  
var wave_display: WaveDisplay = null

func _ready():
	await get_tree().process_frame

	# Créer le WaveSpawner
	var WaveSpawnerScript = load("res://Scripts/WaveSpawner.gd")
	var spawner_node = Node2D.new()
	spawner_node.set_script(WaveSpawnerScript)
	spawner_node.name = "WaveSpawner"
	spawner_node.add_to_group("wave_spawner")
	wave_spawner = spawner_node

	# Charger la scène de zombie depuis la scène
	if zombie_scene:
		wave_spawner.zombie_scene = zombie_scene
	else:
		# Fallback
		var zombie_path = "res://Scenes/Ennemies/Zombies.tscn"
		if ResourceLoader.exists(zombie_path):
			wave_spawner.zombie_scene = load(zombie_path)

	get_tree().current_scene.add_child(wave_spawner)
	print("✓ WaveSpawner créé")

	# Créer le WaveDisplay UI
	var WaveDisplayScene = load("res://Scenes/UI/WaveDisplay.tscn")
	if WaveDisplayScene:
		wave_display = WaveDisplayScene.instantiate()

		# Ajouter à un CanvasLayer
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "WaveDisplayLayer"
		get_tree().current_scene.add_child(canvas_layer)
		canvas_layer.add_child(wave_display)

		print("✓ WaveDisplay créé")
	else:
		print("❌ Impossible de charger WaveDisplay.tscn")

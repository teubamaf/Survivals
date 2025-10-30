extends Node

## Manager pour l'affichage des munitions
## Instancie et gère l'AmmoDisplay

var ammo_display: AmmoDisplay = null

func _ready():
	# Attendre que la scène soit prête
	await get_tree().process_frame

	# Charger et instancier l'AmmoDisplay
	var AmmoDisplayScene = load("res://Scenes/UI/AmmoDisplay.tscn")
	if AmmoDisplayScene:
		ammo_display = AmmoDisplayScene.instantiate()

		# Ajouter à un CanvasLayer pour qu'il soit toujours au-dessus
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "AmmoDisplayLayer"
		get_tree().current_scene.add_child(canvas_layer)
		canvas_layer.add_child(ammo_display)

		print("✓ AmmoDisplay créé et ajouté")
	else:
		print("❌ Impossible de charger AmmoDisplay.tscn")

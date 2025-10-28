extends Node

## Instancie l'UI d'inventaire 7x3

var inventory_ui: InventoryUI = null
var player: Player = null

func _ready():
	await get_tree().create_timer(0.1).timeout

	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("❌ InventoryUIManager: Joueur non trouvé")
		return

	var inventory_ui_scene = load("res://Scenes/InventoryUI.tscn")
	if not inventory_ui_scene:
		print("❌ InventoryUIManager: Scène InventoryUI non trouvée")
		return

	inventory_ui = inventory_ui_scene.instantiate()
	inventory_ui.player = player

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	canvas_layer.add_child(inventory_ui)

	print("✓ UI d'inventaire initialisée")

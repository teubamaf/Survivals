extends Node

var crafting_ui: CraftingUI = null
var player: Player = null

func _ready():
	# Attendre que le joueur soit prêt
	await get_tree().create_timer(0.1).timeout

	# Trouver le joueur
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("❌ CraftingUIManager: Joueur non trouvé")
		return

	# Charger et instancier l'UI de crafting
	var crafting_ui_scene = load("res://Scenes/CraftingUI.tscn")
	if not crafting_ui_scene:
		print("❌ CraftingUIManager: Scène CraftingUI non trouvée")
		return

	crafting_ui = crafting_ui_scene.instantiate()
	crafting_ui.player = player

	# Ajouter l'UI au CanvasLayer pour qu'elle soit toujours visible
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Au-dessus de tout
	add_child(canvas_layer)
	canvas_layer.add_child(crafting_ui)

	print("✓ UI de crafting initialisée")

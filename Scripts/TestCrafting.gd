extends Node

## Script de test pour le système de crafting
## Ajoutez ce script à un Node dans votre scène principale pour tester

func _ready():
	# Attendre que le joueur soit prêt
	await get_tree().create_timer(0.5).timeout

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("❌ Erreur: Joueur non trouvé")
		return

	print("\n🔧 === TEST DU SYSTÈME DE CRAFTING ===\n")

	# Test 1: Vérifier que les systèmes sont initialisés
	print("✓ Test 1: Vérification de l'initialisation")
	if player.resource_inventory:
		print("  ✓ ResourceInventory initialisé")
	else:
		print("  ❌ ResourceInventory non initialisé")
		return

	if player.crafting_manager:
		print("  ✓ CraftingManager initialisé")
	else:
		print("  ❌ CraftingManager non initialisé")
		return

	# Test 2: Vérifier le chargement des recettes
	print("\n✓ Test 2: Vérification des recettes")
	var recipes = player.crafting_manager.get_all_recipes()
	print("  ✓ " + str(recipes.size()) + " recettes chargées")

	# Test 3: Ajouter des ressources
	print("\n✓ Test 3: Ajout de ressources")
	player.add_resources("wood", 50)
	player.add_resources("stone", 30)
	print("  ✓ Bois: " + str(player.resource_inventory.get_resource("wood")))
	print("  ✓ Pierre: " + str(player.resource_inventory.get_resource("stone")))

	# Test 4: Afficher les recettes craftables
	print("\n✓ Test 4: Recettes craftables")
	var craftable = player.crafting_manager.get_craftable_recipes(player.resource_inventory)
	print("  ✓ " + str(craftable.size()) + " recettes craftables:")
	for recipe in craftable:
		print("    - " + recipe.item_name)

	# Test 5: Crafter un item
	print("\n✓ Test 5: Test de crafting")
	var success = player.craft_item("Hache en Pierre")
	if success:
		print("  ✓ Hache en Pierre craftée avec succès!")
		print("  ✓ Bois restant: " + str(player.resource_inventory.get_resource("wood")))
		print("  ✓ Pierre restante: " + str(player.resource_inventory.get_resource("stone")))
	else:
		print("  ❌ Échec du craft")

	print("\n🎮 === FIN DES TESTS ===")
	print("Appuyez sur C pour ouvrir le menu de crafting\n")

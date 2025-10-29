extends Node
class_name CraftingManager

## Gestionnaire central du système de crafting
## Gère toutes les recettes et les opérations de craft

signal item_crafted(recipe: CraftingRecipe, item: Node)
signal craft_failed(recipe: CraftingRecipe, reason: String)

## Liste de toutes les recettes disponibles
var recipes: Array[CraftingRecipe] = []

## Référence au joueur (pour accéder à son inventaire)
var player: Player = null

func _ready():
	# Charge toutes les recettes depuis la base de données
	_load_all_recipes()

## Charge toutes les recettes depuis le RecipeDatabase
func _load_all_recipes():
	var RecipeDatabaseScript = load("res://Scripts/Crafting/RecipeDatabase.gd")
	var all_recipes = RecipeDatabaseScript.load_all_recipes()
	for recipe in all_recipes:
		register_recipe(recipe)
	print("Chargé ", recipes.size(), " recettes de craft")

## Enregistre une nouvelle recette
func register_recipe(recipe: CraftingRecipe):
	if recipe and not recipes.has(recipe):
		recipes.append(recipe)
		print("Recette enregistrée: " + recipe.item_name)

## Supprime une recette
func unregister_recipe(recipe: CraftingRecipe):
	recipes.erase(recipe)

## Récupère toutes les recettes
func get_all_recipes() -> Array[CraftingRecipe]:
	return recipes

## Récupère les recettes par catégorie
func get_recipes_by_category(category: String) -> Array[CraftingRecipe]:
	var filtered: Array[CraftingRecipe] = []
	for recipe in recipes:
		if recipe.category == category:
			filtered.append(recipe)
	return filtered

## Récupère les recettes par type
func get_recipes_by_type(item_type: String) -> Array[CraftingRecipe]:
	var filtered: Array[CraftingRecipe] = []
	for recipe in recipes:
		if recipe.item_type == item_type:
			filtered.append(recipe)
	return filtered

## Récupère les recettes craftables avec les ressources actuelles
func get_craftable_recipes(resource_inventory: ResourceInventory) -> Array[CraftingRecipe]:
	var craftable: Array[CraftingRecipe] = []
	for recipe in recipes:
		if recipe.can_craft(resource_inventory.get_all_resources()):
			craftable.append(recipe)
	return craftable

## Craft un item depuis une recette
func craft_item(recipe: CraftingRecipe, resource_inventory: ResourceInventory, target_player: Player = null) -> Node:
	# Vérifie si on peut crafter
	if not recipe.can_craft(resource_inventory.get_all_resources()):
		var missing = recipe.get_missing_resources(resource_inventory.get_all_resources())
		var reason = "Ressources manquantes: "
		for res in missing:
			reason += res + " (" + str(missing[res]) + ") "
		craft_failed.emit(recipe, reason)
		print("Craft échoué: " + reason)
		return null

	# Retire les ressources
	if not resource_inventory.remove_resources(recipe.required_resources):
		craft_failed.emit(recipe, "Erreur lors du retrait des ressources")
		return null

	# Crée l'item
	var crafted_item = null

	if recipe.result_scene:
		# Utilise la scène définie
		crafted_item = recipe.result_scene.instantiate()
	elif recipe.item_type == "Weapon":
		# Crée une arme basique si pas de scène (utilise la hache par défaut)
		var default_weapon_scene = load("res://Scenes/Weapon/Weapon_Axe.tscn")
		if default_weapon_scene:
			crafted_item = default_weapon_scene.instantiate()
			if crafted_item is Weapon:
				crafted_item.weapon_name = recipe.item_name
			print("⚠ Arme créée avec template par défaut: " + recipe.item_name)

	if crafted_item and target_player:
		# Si c'est une arme, l'ajoute à l'inventaire
		if crafted_item is Weapon:
			target_player.add_weapon_to_inventory(crafted_item)
			print("✓ Arme craftée et ajoutée: " + recipe.item_name)
		else:
			# Sinon, spawn près du joueur
			target_player.get_parent().add_child(crafted_item)
			crafted_item.global_position = target_player.global_position + Vector2(50, 0)
			print("✓ Item crafté: " + recipe.item_name)
	elif not crafted_item:
		print("❌ Impossible de créer: " + recipe.item_name)

	item_crafted.emit(recipe, crafted_item)
	return crafted_item

## Trouve une recette par nom
func find_recipe_by_name(item_name: String) -> CraftingRecipe:
	for recipe in recipes:
		if recipe.item_name == item_name:
			return recipe
	return null

## Affiche toutes les recettes (debug)
func print_all_recipes():
	print("=== Recettes de Crafting ===")
	for recipe in recipes:
		print("\n" + recipe.get_recipe_text())

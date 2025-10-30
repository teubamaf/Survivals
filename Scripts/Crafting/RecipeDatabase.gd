extends Node
class_name RecipeDatabase

## Base de données centralisée pour toutes les recettes de craft
## Facilite l'ajout de nouvelles recettes

## Charge et retourne toutes les recettes disponibles
static func load_all_recipes() -> Array[CraftingRecipe]:
	var recipes: Array[CraftingRecipe] = []

	# Recettes d'armes basiques
	recipes.append(_create_wooden_club())
	recipes.append(_create_stone_axe())
	recipes.append(_create_wooden_spear())
	recipes.append(_create_stone_sword())
	recipes.append(_create_slingshot())

	# Recettes d'outils
	recipes.append(_create_stone_pickaxe())
	recipes.append(_create_wooden_shield())

	# Recettes de structures
	recipes.append(_create_campfire())
	recipes.append(_create_wooden_wall())
	recipes.append(_create_stone_barricade())

	return recipes

## === ARMES ===

static func _create_wooden_club() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Massue en Bois"
	recipe.description = "Arme de mêlée basique. Efficace contre les zombies."
	recipe.required_resources = {"wood": 5}
	recipe.item_type = "Weapon"
	recipe.category = "Basic"
	return recipe

static func _create_stone_axe() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Hache en Pierre"
	recipe.description = "Hache robuste. Dégâts moyens, peut couper les arbres plus vite."
	recipe.required_resources = {"wood": 3, "stone": 5}
	recipe.item_type = "Weapon"
	recipe.category = "Basic"
	# Réutilise la hache existante si disponible
	if ResourceLoader.exists("res://Scenes/AxeWeapon.tscn"):
		recipe.result_scene = load("res://Scenes/AxeWeapon.tscn")
	return recipe

static func _create_wooden_spear() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Lance en Bois"
	recipe.description = "Arme à portée moyenne. Bonne pour garder les ennemis à distance."
	recipe.required_resources = {"wood": 8, "stone": 2}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

static func _create_stone_sword() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Épée en Pierre"
	recipe.description = "Arme tranchante. Dégâts élevés, attaque rapide."
	recipe.required_resources = {"wood": 2, "stone": 10}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

static func _create_slingshot() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Fronde"
	recipe.description = "Arme à distance simple. Lance des pierres."
	recipe.required_resources = {"wood": 4, "stone": 2}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

## === OUTILS ===

static func _create_stone_pickaxe() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Pioche en Pierre"
	recipe.description = "Pioche solide. Mine les roches 2x plus vite."
	recipe.required_resources = {"wood": 3, "stone": 6}
	recipe.item_type = "Tool"
	recipe.category = "Basic"
	return recipe

static func _create_wooden_shield() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Bouclier en Bois"
	recipe.description = "Bouclier de base. Réduit les dégâts reçus de 30%."
	recipe.required_resources = {"wood": 12}
	recipe.item_type = "Tool"
	recipe.category = "Combat"
	return recipe

## === STRUCTURES ===

static func _create_campfire() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Feu de Camp"
	recipe.description = "Source de lumière et de chaleur. Permet de cuisiner."
	recipe.required_resources = {"wood": 10, "stone": 5}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	return recipe

static func _create_wooden_wall() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Mur en Bois"
	recipe.description = "Mur défensif. Bloque les ennemis et les projectiles."
	recipe.required_resources = {"wood": 5}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	recipe.result_scene = load("res://Scenes/Buildings/Walls/Wood_Wall.tscn")

	# Créer une AtlasTexture pour extraire juste la région du mur
	var atlas = AtlasTexture.new()
	atlas.atlas = load("res://Assets/Tilemap/Ressources/tilemap.png")
	atlas.region = Rect2(152.96355, 106.95225, 16.012833, 8.087288)
	recipe.icon = atlas

	return recipe

static func _create_stone_barricade() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Barricade en Pierre"
	recipe.description = "Barricade solide. Haute résistance aux attaques."
	recipe.required_resources = {"wood": 8, "stone": 20}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	return recipe

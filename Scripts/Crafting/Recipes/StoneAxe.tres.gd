# Recette: Hache en Pierre
# Outil et arme, plus puissant que la massue
# Coût: 3 bois + 5 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Hache en Pierre"
	recipe.description = "Hache robuste. Dégâts moyens, peut couper les arbres plus vite."
	recipe.required_resources = {
		"wood": 3,
		"stone": 5
	}
	recipe.item_type = "Weapon"
	recipe.category = "Basic"
	# Peut réutiliser le AxeWeapon existant
	recipe.result_scene = load("res://Scenes/AxeWeapon.tscn")
	return recipe

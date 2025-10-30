# Recette: Mur en Bois
# Structure défensive de base
# Coût: 15 bois

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Mur en Bois"
	recipe.description = "Mur défensif. Bloque les ennemis et les projectiles."
	recipe.required_resources = {
		"wood": 5
	}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	recipe.result_scene = load("res://Scenes/Buildings/Walls/Wood_Wall.tscn")
	return recipe

# Recette: Massue en Bois
# Item de combat de base pour débutant
# Coût: 5 bois

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Massue en Bois"
	recipe.description = "Arme de mêlée basique. Efficace contre les zombies."
	recipe.required_resources = {
		"wood": 5
	}
	recipe.item_type = "Weapon"
	recipe.category = "Basic"
	# Note: Le result_scene devra être assigné manuellement ou créé
	return recipe

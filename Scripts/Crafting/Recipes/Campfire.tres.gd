# Recette: Feu de Camp
# Structure de base pour la cuisson et la lumière
# Coût: 10 bois + 5 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Feu de Camp"
	recipe.description = "Source de lumière et de chaleur. Permet de cuisiner."
	recipe.required_resources = {
		"wood": 10,
		"stone": 5
	}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	return recipe

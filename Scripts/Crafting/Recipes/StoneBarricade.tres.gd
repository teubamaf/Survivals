# Recette: Barricade en Pierre
# Structure défensive renforcée
# Coût: 8 bois + 20 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Barricade en Pierre"
	recipe.description = "Barricade solide. Haute résistance aux attaques."
	recipe.required_resources = {
		"wood": 8,
		"stone": 20
	}
	recipe.item_type = "Structure"
	recipe.category = "Building"
	return recipe

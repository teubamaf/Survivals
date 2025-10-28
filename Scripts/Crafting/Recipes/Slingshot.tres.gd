# Recette: Fronde
# Arme à distance basique
# Coût: 4 bois + 2 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Fronde"
	recipe.description = "Arme à distance simple. Lance des pierres."
	recipe.required_resources = {
		"wood": 4,
		"stone": 2
	}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

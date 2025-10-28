# Recette: Lance en Bois
# Arme de mêlée avec plus de portée
# Coût: 8 bois + 2 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Lance en Bois"
	recipe.description = "Arme à portée moyenne. Bonne pour garder les ennemis à distance."
	recipe.required_resources = {
		"wood": 8,
		"stone": 2
	}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

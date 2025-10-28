# Recette: Pioche en Pierre
# Outil pour miner plus efficacement
# Coût: 3 bois + 6 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Pioche en Pierre"
	recipe.description = "Pioche solide. Mine les roches 2x plus vite."
	recipe.required_resources = {
		"wood": 3,
		"stone": 6
	}
	recipe.item_type = "Tool"
	recipe.category = "Basic"
	return recipe

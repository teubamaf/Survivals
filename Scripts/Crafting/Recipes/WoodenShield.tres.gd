# Recette: Bouclier en Bois
# Équipement défensif
# Coût: 12 bois

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Bouclier en Bois"
	recipe.description = "Bouclier de base. Réduit les dégâts reçus de 30%."
	recipe.required_resources = {
		"wood": 12
	}
	recipe.item_type = "Tool"
	recipe.category = "Combat"
	return recipe

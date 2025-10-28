# Recette: Épée en Pierre
# Arme avancée avec bons dégâts et vitesse
# Coût: 2 bois + 10 pierres

extends Resource

static func create() -> CraftingRecipe:
	var recipe = CraftingRecipe.new()
	recipe.item_name = "Épée en Pierre"
	recipe.description = "Arme tranchante. Dégâts élevés, attaque rapide."
	recipe.required_resources = {
		"wood": 2,
		"stone": 10
	}
	recipe.item_type = "Weapon"
	recipe.category = "Combat"
	return recipe

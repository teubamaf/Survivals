extends Resource
class_name CraftingRecipe

## Système de recette de craft extensible
## Permet de définir facilement de nouvelles recettes avec ressources et résultats

## Nom de l'item craftable
@export var item_name: String = ""

## Description de l'item
@export var description: String = ""

## Icône de l'item (optionnel)
@export var icon: Texture2D

## Ressources nécessaires pour crafter (nom de la ressource)
@export var required_resources: Dictionary = {}
# Exemple: {"wood": 10, "stone": 5}

## Scène de l'item à spawner après le craft (pour les armes/objets)
@export var result_scene: PackedScene

## Type d'item crafté (pour différencier arme/outil/structure)
@export_enum("Weapon", "Tool", "Structure", "Consumable") var item_type: String = "Tool"

## Catégorie pour l'UI (facilite l'organisation)
@export_enum("Basic", "Advanced", "Combat", "Building") var category: String = "Basic"

## Vérifie si le joueur a assez de ressources pour crafter
func can_craft(player_resources: Dictionary) -> bool:
	for resource_name in required_resources:
		var required_amount = required_resources[resource_name]
		if not player_resources.has(resource_name):
			return false
		if player_resources[resource_name] < required_amount:
			return false
	return true

## Retourne les ressources manquantes
func get_missing_resources(player_resources: Dictionary) -> Dictionary:
	var missing = {}
	for resource_name in required_resources:
		var required_amount = required_resources[resource_name]
		var current_amount = player_resources.get(resource_name, 0)
		if current_amount < required_amount:
			missing[resource_name] = required_amount - current_amount
	return missing

## Retourne une description formatée des ressources nécessaires
func get_recipe_text() -> String:
	var text = item_name + "\n"
	text += description + "\n\n"
	text += "Ressources nécessaires:\n"
	for resource_name in required_resources:
		text += "- " + resource_name.capitalize() + ": " + str(required_resources[resource_name]) + "\n"
	return text

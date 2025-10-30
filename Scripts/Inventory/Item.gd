extends Resource
class_name Item

## Classe de base pour tous les items (armes, structures, consommables, etc.)

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export_enum("Weapon", "Structure", "Consumable", "Tool") var item_type: String = "Weapon"

## Scène à instancier quand on utilise l'item
@export var scene: PackedScene

## Pour les armes : référence directe
var weapon_instance: Weapon = null

## Pour les structures : référence à la scène
var structure_scene: PackedScene = null

## Quantité d'items stackés (pour les structures et consommables)
var quantity: int = 1

## Crée un Item depuis une arme
static func from_weapon(weapon: Weapon) -> Item:
	var item = Item.new()
	item.item_name = weapon.weapon_name if weapon.weapon_name else "Arme"
	item.item_type = "Weapon"
	item.weapon_instance = weapon

	# Essaye de récupérer l'icône depuis le sprite
	var sprite = weapon.get_node_or_null("Sprite2D")
	if sprite and sprite is Sprite2D:
		item.icon = sprite.texture

	return item

## Crée un Item depuis une recette de structure
static func from_structure_recipe(recipe: CraftingRecipe) -> Item:
	var item = Item.new()
	item.item_name = recipe.item_name
	item.description = recipe.description
	item.item_type = "Structure"
	item.structure_scene = recipe.result_scene
	item.icon = recipe.icon
	return item

## Utilise l'item
func use(player: Player, slot_index: int = -1) -> bool:
	if item_type == "Weapon" and weapon_instance:
		# Équipe l'arme
		player.equip_weapon(weapon_instance)
		return true
	elif item_type == "Structure" and structure_scene and player.building_placer:
		# Active le mode placement et passe le slot_index pour décrémenter après placement
		player.building_placer.start_placing_with_decrement(structure_scene, player, slot_index)
		return true
	return false

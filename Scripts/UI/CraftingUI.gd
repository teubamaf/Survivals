extends Control
class_name CraftingUI

## Interface de crafting avec liste de recettes et informations

@export var player: Player

## Conteneurs UI
@onready var recipe_list_container: VBoxContainer = $MainPanel/MarginContainer/VBoxContainer/ContentContainer/RecipeListPanel/VBoxContainer/ScrollContainer/RecipeList
@onready var recipe_info_container: VBoxContainer = $MainPanel/MarginContainer/VBoxContainer/ContentContainer/RecipeInfoPanel/VBoxContainer/ScrollContainer/InfoContainer
@onready var resource_display: HBoxContainer = $MainPanel/MarginContainer/VBoxContainer/ResourceDisplay
@onready var close_button: Button = $MainPanel/MarginContainer/VBoxContainer/CloseButton

## Recette actuellement sélectionnée
var selected_recipe: CraftingRecipe = null

## Couleurs pour l'affichage
const COLOR_AVAILABLE = Color(0.3, 1.0, 0.3)  # Vert
const COLOR_UNAVAILABLE = Color(1.0, 0.3, 0.3)  # Rouge
const COLOR_SELECTED = Color(0.5, 0.7, 1.0)  # Bleu

signal crafting_ui_opened
signal crafting_ui_closed
signal item_crafted(recipe: CraftingRecipe)

var is_open: bool = false

func _ready():
	# Cache l'UI au démarrage
	hide()

	# Connecte le bouton fermer
	if close_button:
		close_button.pressed.connect(close_ui)

func _setup_ui_structure():
	# Cette fonction peut être étendue pour créer l'UI programmatiquement
	# ou vous pouvez créer l'UI directement dans l'éditeur Godot
	pass

func _input(event):
	# Touche C pour ouvrir/fermer le menu de craft
	if event.is_action_pressed("ui_cancel") and is_open:
		close_ui()
	elif event.is_action_pressed("craft_menu"):
		if is_open:
			close_ui()
		else:
			open_ui()

func open_ui():
	if not player or not player.crafting_manager:
		print("Erreur: Player ou CraftingManager non initialisé")
		return

	is_open = true
	show()
	get_tree().paused = true
	_refresh_recipe_list()
	_update_resource_display()
	crafting_ui_opened.emit()

func close_ui():
	is_open = false
	hide()
	get_tree().paused = false
	crafting_ui_closed.emit()

## Rafraîchit la liste des recettes
func _refresh_recipe_list():
	if not recipe_list_container:
		return

	# Efface la liste actuelle
	for child in recipe_list_container.get_children():
		child.queue_free()

	# Récupère toutes les recettes
	var recipes = player.crafting_manager.get_all_recipes()

	# Crée un bouton pour chaque recette
	for recipe in recipes:
		var button = _create_recipe_button(recipe)
		recipe_list_container.add_child(button)

## Crée un bouton pour une recette
func _create_recipe_button(recipe: CraftingRecipe) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 40)
	button.text = recipe.item_name
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Vérifie si craftable
	var can_craft = recipe.can_craft(player.resource_inventory.get_all_resources())

	# Ajoute un indicateur visuel
	if can_craft:
		button.text = "✓ " + recipe.item_name
		button.modulate = COLOR_AVAILABLE
	else:
		button.text = "✗ " + recipe.item_name
		button.modulate = COLOR_UNAVAILABLE

	# Connecte le signal
	button.pressed.connect(_on_recipe_button_pressed.bind(recipe))

	return button

## Appelé quand on clique sur une recette
func _on_recipe_button_pressed(recipe: CraftingRecipe):
	selected_recipe = recipe
	_display_recipe_info(recipe)

## Affiche les informations d'une recette
func _display_recipe_info(recipe: CraftingRecipe):
	if not recipe_info_container:
		return

	# Efface les infos actuelles
	for child in recipe_info_container.get_children():
		child.queue_free()

	# Nom de l'item
	var title_label = Label.new()
	title_label.text = recipe.item_name
	title_label.add_theme_font_size_override("font_size", 24)
	recipe_info_container.add_child(title_label)

	# Séparateur
	var separator1 = HSeparator.new()
	recipe_info_container.add_child(separator1)

	# Description
	var desc_label = Label.new()
	desc_label.text = recipe.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recipe_info_container.add_child(desc_label)

	# Séparateur
	var separator2 = HSeparator.new()
	recipe_info_container.add_child(separator2)

	# Ressources nécessaires
	var req_title = Label.new()
	req_title.text = "Ressources nécessaires:"
	req_title.add_theme_font_size_override("font_size", 18)
	recipe_info_container.add_child(req_title)

	var resources = player.resource_inventory.get_all_resources()
	for resource_name in recipe.required_resources:
		var needed = recipe.required_resources[resource_name]
		var has = resources.get(resource_name, 0)

		var res_label = Label.new()
		res_label.text = "  • " + resource_name.capitalize() + ": " + str(has) + "/" + str(needed)

		# Colore en vert si assez, rouge si pas assez
		if has >= needed:
			res_label.add_theme_color_override("font_color", COLOR_AVAILABLE)
		else:
			res_label.add_theme_color_override("font_color", COLOR_UNAVAILABLE)

		recipe_info_container.add_child(res_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	recipe_info_container.add_child(spacer)

	# Bouton de craft
	var craft_button = Button.new()
	craft_button.text = "CRAFTER"
	craft_button.custom_minimum_size = Vector2(0, 50)
	craft_button.pressed.connect(_on_craft_button_pressed.bind(recipe))

	# Désactive le bouton si pas assez de ressources
	var can_craft = recipe.can_craft(resources)
	craft_button.disabled = not can_craft

	recipe_info_container.add_child(craft_button)

## Appelé quand on clique sur le bouton Craft
func _on_craft_button_pressed(recipe: CraftingRecipe):
	if not player or not player.crafting_manager:
		return

	# Tente de crafter l'item
	var crafted_item = player.crafting_manager.craft_item(
		recipe,
		player.resource_inventory,
		player
	)

	if crafted_item:
		print("Item crafté avec succès: " + recipe.item_name)
		item_crafted.emit(recipe)
		# Rafraîchit l'UI
		_refresh_recipe_list()
		_update_resource_display()
		_display_recipe_info(recipe)  # Rafraîchit les infos de la recette

## Met à jour l'affichage des ressources
func _update_resource_display():
	if not resource_display or not player:
		return

	# Efface l'affichage actuel
	for child in resource_display.get_children():
		child.queue_free()

	# Affiche chaque ressource principale (pas les ressources à 0)
	var resources = player.resource_inventory.get_all_resources()
	for resource_name in ["wood", "stone"]:  # Seulement bois et pierre pour l'instant
		if resources.has(resource_name):
			var amount = resources[resource_name]

			# Panel pour chaque ressource
			var res_panel = PanelContainer.new()
			var res_hbox = HBoxContainer.new()
			res_panel.add_child(res_hbox)

			# Label de la ressource
			var label = Label.new()
			label.text = resource_name.capitalize() + ": " + str(amount)
			label.add_theme_font_size_override("font_size", 16)
			res_hbox.add_child(label)

			resource_display.add_child(res_panel)

## Version simple pour afficher dans la console
func print_crafting_menu():
	if not player or not player.crafting_manager:
		print("Erreur: Player ou CraftingManager non initialisé")
		return

	print("\n=== MENU DE CRAFTING ===")

	# Affiche les ressources
	print("\n--- Ressources disponibles ---")
	var resources = player.resource_inventory.get_all_resources()
	for resource_name in resources:
		print("- " + resource_name.capitalize() + ": " + str(resources[resource_name]))

	# Affiche les recettes
	print("\n--- Recettes disponibles ---")
	var recipes = player.crafting_manager.get_all_recipes()
	var index = 1
	for recipe in recipes:
		var can_craft = recipe.can_craft(resources)
		var status = "[OK]" if can_craft else "[X]"
		print(str(index) + ". " + status + " " + recipe.item_name)
		index += 1

	print("\n========================")

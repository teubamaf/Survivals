extends PanelContainer
class_name ItemTooltip

## Tooltip qui affiche les informations d'un item au survol

@onready var item_name_label: Label = $MarginContainer/VBoxContainer/ItemName
@onready var description_label: Label = $MarginContainer/VBoxContainer/Description
@onready var quantity_label: Label = $MarginContainer/VBoxContainer/Quantity

func _ready():
	hide()
	# S'assurer que le tooltip est au-dessus de tout
	z_index = 100

func show_tooltip(item: Item, mouse_position: Vector2):
	"""Affiche le tooltip pour un item"""
	if not item:
		hide()
		return

	# Mettre à jour le contenu
	if item_name_label:
		item_name_label.text = item.item_name
		item_name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))  # Jaune doré

	if description_label:
		description_label.text = item.description

	if quantity_label:
		if item.quantity > 1:
			quantity_label.text = "Quantité: " + str(item.quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false

	# Positionner le tooltip près de la souris
	global_position = mouse_position + Vector2(15, 15)

	# S'assurer que le tooltip ne sort pas de l'écran
	var viewport_size = get_viewport_rect().size
	if global_position.x + size.x > viewport_size.x:
		global_position.x = mouse_position.x - size.x - 15
	if global_position.y + size.y > viewport_size.y:
		global_position.y = mouse_position.y - size.y - 15

	show()

func hide_tooltip():
	"""Cache le tooltip"""
	hide()

extends TextureRect
class_name InventorySlot

## Un slot d'inventaire qui peut contenir un item

signal slot_clicked(slot: InventorySlot)
signal item_dropped_on_slot(from_slot: InventorySlot, to_slot: InventorySlot)
signal mouse_entered_slot(slot: InventorySlot)
signal mouse_exited_slot(slot: InventorySlot)

var slot_index: int = -1
var item: Item = null
var is_hotbar_slot: bool = false

var item_sprite: Sprite2D = null
var quantity_label: Label = null

func _ready():
	# Configuration du slot
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(64, 64)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE

	# Charger la texture du slot
	texture = load("res://Assets/UI/Inv/tile_0001.png")

	# Créer le sprite pour l'item
	item_sprite = Sprite2D.new()
	item_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item_sprite.centered = true
	item_sprite.position = Vector2(32, 32)
	add_child(item_sprite)

	# Créer le label pour la quantité
	quantity_label = Label.new()
	quantity_label.position = Vector2(40, 40)
	quantity_label.add_theme_font_size_override("font_size", 14)
	quantity_label.add_theme_color_override("font_color", Color.WHITE)
	quantity_label.add_theme_color_override("font_outline_color", Color.BLACK)
	quantity_label.add_theme_constant_override("outline_size", 2)
	quantity_label.visible = false
	add_child(quantity_label)

	# Connecter les signaux de souris pour le tooltip
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_update_display()

func set_item(new_item: Item):
	item = new_item
	_update_display()

func get_item() -> Item:
	return item

func clear():
	item = null
	_update_display()

func has_item() -> bool:
	return item != null

func _update_display():
	if not item_sprite:
		return

	if item:
		# Si l'item a une icône, l'utilise
		if item.icon:
			item_sprite.texture = item.icon
			item_sprite.scale = Vector2(1.5, 1.5)
			item_sprite.rotation = 0
			item_sprite.visible = true
		# Sinon essaye de récupérer depuis l'arme
		elif item.weapon_instance:
			var weapon_sprite = item.weapon_instance.get_node_or_null("Sprite2D")
			if weapon_sprite and weapon_sprite is Sprite2D:
				item_sprite.texture = weapon_sprite.texture
				item_sprite.scale = weapon_sprite.scale * 1.5
				item_sprite.rotation = 0
				item_sprite.visible = true
			else:
				item_sprite.visible = false
		else:
			item_sprite.visible = false

		# Afficher la quantité si > 1
		if quantity_label:
			if item.quantity > 1:
				quantity_label.text = str(item.quantity)
				quantity_label.visible = true
			else:
				quantity_label.visible = false
	else:
		item_sprite.visible = false
		if quantity_label:
			quantity_label.visible = false

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(self)

func _on_mouse_entered():
	if has_item():
		mouse_entered_slot.emit(self)

func _on_mouse_exited():
	mouse_exited_slot.emit(self)

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("slot")

func _drop_data(_at_position, data):
	if data.has("slot"):
		var from_slot = data["slot"] as InventorySlot
		item_dropped_on_slot.emit(from_slot, self)

func _get_drag_data(_at_position):
	if not has_item():
		return null

	# Créer un aperçu visuel identique au slot
	var preview = TextureRect.new()
	preview.texture = texture
	preview.custom_minimum_size = Vector2(64, 64)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_SCALE
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Ajouter le sprite de l'item
	var preview_sprite = Sprite2D.new()
	preview_sprite.texture = item_sprite.texture
	preview_sprite.scale = item_sprite.scale
	preview_sprite.position = Vector2(32, 32)
	preview_sprite.centered = true
	preview.add_child(preview_sprite)

	set_drag_preview(preview)

	return {"slot": self, "item": item}

extends TextureRect
class_name InventorySlot

## Un slot d'inventaire qui peut contenir un item

signal slot_clicked(slot: InventorySlot)
signal item_dropped_on_slot(from_slot: InventorySlot, to_slot: InventorySlot)

var slot_index: int = -1
var item: Item = null
var is_hotbar_slot: bool = false

var item_sprite: Sprite2D = null

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
			item_sprite.scale = Vector2(0.8, 0.8)
			item_sprite.rotation = 0
			item_sprite.visible = true
		# Sinon essaye de récupérer depuis l'arme
		elif item.weapon_instance:
			var weapon_sprite = item.weapon_instance.get_node_or_null("Sprite2D")
			if weapon_sprite and weapon_sprite is Sprite2D:
				item_sprite.texture = weapon_sprite.texture
				item_sprite.scale = weapon_sprite.scale * 0.8
				item_sprite.rotation = 0
				item_sprite.visible = true
			else:
				item_sprite.visible = false
		else:
			item_sprite.visible = false
	else:
		item_sprite.visible = false

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(self)

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

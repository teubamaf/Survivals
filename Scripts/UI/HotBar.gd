extends Control

## Configuration de la barre d'armes
@export var num_slots: int = 7
@export var slot_size: int = 64
@export var slot_spacing: int = 8
@export var selected_slot: int = 0

@onready var slots_container = $SlotsContainer

var player: Player = null
var weapon_icons: Array[Sprite2D] = []
var quantity_labels: Array[Label] = []

func _ready():
	# Créer les sprites pour les icônes d'armes et les labels de quantité
	for i in range(num_slots):
		var weapon_icon = Sprite2D.new()
		weapon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		weapon_icon.visible = false
		weapon_icon.centered = true
		weapon_icon.position = Vector2(32, 32)  # Centre du slot 64x64
		slots_container.get_child(i).add_child(weapon_icon)
		weapon_icons.append(weapon_icon)

		# Créer le label pour la quantité
		var quantity_label = Label.new()
		quantity_label.position = Vector2(40, 40)
		quantity_label.add_theme_font_size_override("font_size", 14)
		quantity_label.add_theme_color_override("font_color", Color.WHITE)
		quantity_label.add_theme_color_override("font_outline_color", Color.BLACK)
		quantity_label.add_theme_constant_override("outline_size", 2)
		quantity_label.visible = false
		slots_container.get_child(i).add_child(quantity_label)
		quantity_labels.append(quantity_label)


	update_selection()


	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		connect_to_player()

func connect_to_player():
	if not player:
		return

	# Se connecter aux signaux du joueur pour mettre à jour l'inventaire
	if not player.weapon_equipped.is_connected(_on_weapon_equipped):
		player.weapon_equipped.connect(_on_weapon_equipped)

	if not player.inventory_changed.is_connected(_on_inventory_changed):
		player.inventory_changed.connect(_on_inventory_changed)

	# Mise à jour initiale de l'inventaire
	update_inventory_display()

func _on_weapon_equipped(weapon: Weapon):
	update_inventory_display()

func _on_inventory_changed():
	update_inventory_display()

func update_inventory_display():
	if not player:
		return

	# Effacer tous les slots
	for i in range(num_slots):
		weapon_icons[i].visible = false
		quantity_labels[i].visible = false

	# Afficher les items du nouveau système d'inventaire
	if player.inventory_system:
		for i in range(num_slots):
			var item = player.inventory_system.get_item(i)
			if item:
				_display_item_in_slot(i, item)

	update_selection()

func _display_item_in_slot(slot_index: int, item: Item):
	if slot_index < 0 or slot_index >= weapon_icons.size():
		return

	# Si l'item a une icône
	if item.icon:
		weapon_icons[slot_index].texture = item.icon
		weapon_icons[slot_index].scale = Vector2(1.5, 1.5)
		weapon_icons[slot_index].rotation = 0
		weapon_icons[slot_index].visible = true
	# Sinon essaye de récupérer depuis l'arme
	elif item.weapon_instance:
		var weapon_sprite = item.weapon_instance.get_node_or_null("Sprite2D")
		if weapon_sprite and weapon_sprite is Sprite2D:
			weapon_icons[slot_index].texture = weapon_sprite.texture
			weapon_icons[slot_index].scale = weapon_sprite.scale * 1.5
			weapon_icons[slot_index].rotation = 0
			weapon_icons[slot_index].visible = true

	# Afficher la quantité si > 1
	if item.quantity > 1:
		quantity_labels[slot_index].text = str(item.quantity)
		quantity_labels[slot_index].visible = true

func _input(event):
	# Sélection des slots avec les touches 1-7
	if event is InputEventKey and event.pressed:
		for i in range(num_slots):
			if event.keycode == KEY_1 + i:
				select_slot(i)
				break

func select_slot(slot_index: int):
	if slot_index >= 0 and slot_index < num_slots and player:
		selected_slot = slot_index
		# Utilise l'item du slot
		if player.inventory_system:
			var item = player.inventory_system.get_item(slot_index)
			if item:
				item.use(player, slot_index)
		update_selection()

func update_selection():
	# Mettre à jour visuellement le slot sélectionné
	for i in range(slots_container.get_child_count()):
		var slot = slots_container.get_child(i)
		if i == selected_slot:
			slot.modulate = Color(1, 1, 1, 1)  # Slot sélectionné en blanc
			slot.scale = Vector2(1.1, 1.1)  # Légèrement plus grand
		else:
			slot.modulate = Color(0.7, 0.7, 0.7, 1)  # Slots non sélectionnés plus sombres
			slot.scale = Vector2(1, 1)

extends Control

## Configuration de la barre d'armes
@export var num_slots: int = 7
@export var slot_size: int = 64
@export var slot_spacing: int = 8
@export var selected_slot: int = 0

@onready var slots_container = $SlotsContainer

var player: Player = null
var weapon_icons: Array[Sprite2D] = []

func _ready():
	# Créer les sprites pour les icônes d'armes
	for i in range(num_slots):
		var weapon_icon = Sprite2D.new()
		weapon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		weapon_icon.visible = false
		weapon_icon.centered = true
		weapon_icon.position = Vector2(32, 32)  # Centre du slot 64x64
		slots_container.get_child(i).add_child(weapon_icon)
		weapon_icons.append(weapon_icon)

	# La barre se positionne automatiquement en bas au centre grâce aux anchors
	update_selection()

	# Trouver le joueur et se connecter à ses signaux
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

	# Afficher les armes de l'inventaire
	for i in range(min(player.inventory.size(), num_slots)):
		var weapon = player.inventory[i]
		if weapon:
			_display_weapon_in_slot(i, weapon)

	# Mettre à jour la sélection pour montrer l'arme équipée
	if player.current_weapon and player.current_weapon in player.inventory:
		selected_slot = player.inventory.find(player.current_weapon)

	update_selection()

func _display_weapon_in_slot(slot_index: int, weapon: Weapon):
	if slot_index < 0 or slot_index >= weapon_icons.size():
		return

	var weapon_sprite = weapon.get_node_or_null("Sprite2D")
	if weapon_sprite and weapon_sprite is Sprite2D:
		weapon_icons[slot_index].texture = weapon_sprite.texture
		weapon_icons[slot_index].scale = weapon_sprite.scale * 0.8
		weapon_icons[slot_index].rotation = 0
		weapon_icons[slot_index].visible = true

func _input(event):
	# Sélection des slots avec les touches 1-7
	if event is InputEventKey and event.pressed:
		for i in range(num_slots):
			if event.keycode == KEY_1 + i:
				select_slot(i)
				break

func select_slot(slot_index: int):
	if slot_index >= 0 and slot_index < num_slots and player:
		# Vérifier qu'il y a une arme dans ce slot
		if slot_index < player.inventory.size():
			selected_slot = slot_index
			player.equip_weapon(player.inventory[slot_index])
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

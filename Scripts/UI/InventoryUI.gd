extends Control
class_name InventoryUI

## UI du sac complet 7x3 slots

@export var player: Player

var slots: Array[InventorySlot] = []
var inventory_system: InventorySystem
var tooltip: ItemTooltip = null

const COLUMNS = 7
const ROWS = 3

@onready var grid_container: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer

signal inventory_opened
signal inventory_closed

var is_open: bool = false

func _ready():
	hide()

	# Créer le tooltip
	var TooltipScene = load("res://Scenes/UI/ItemTooltip.tscn")
	tooltip = TooltipScene.instantiate()
	add_child(tooltip)

	# Attendre que tous les nodes soient prêts
	await get_tree().process_frame

	# Configurer le grid
	if grid_container:
		grid_container.columns = COLUMNS
		print("✓ InventoryUI: GridContainer trouvé, création de ", COLUMNS * ROWS, " slots")

		# Créer les 21 slots
		for i in range(COLUMNS * ROWS):
			var slot = InventorySlot.new()
			slot.slot_index = i
			slot.is_hotbar_slot = (i < 7)  # Première ligne = hotbar
			slot.slot_clicked.connect(_on_slot_clicked)
			slot.item_dropped_on_slot.connect(_on_item_dropped)
			slot.mouse_entered_slot.connect(_on_slot_mouse_entered)
			slot.mouse_exited_slot.connect(_on_slot_mouse_exited)

			# Ajouter une bordure plus visible pour la hotbar
			if slot.is_hotbar_slot:
				slot.modulate = Color(1.2, 1.2, 1.0)  # Légèrement jaune

			grid_container.add_child(slot)
			slots.append(slot)

		print("✓ InventoryUI: ", slots.size(), " slots créés")
	else:
		print("❌ InventoryUI: GridContainer non trouvé !")

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_open:
		close_inventory()
	elif event.is_action_pressed("inventory_toggle"):
		if is_open:
			close_inventory()
		else:
			open_inventory()

func open_inventory():
	if not player or not player.inventory_system:
		return

	inventory_system = player.inventory_system
	is_open = true
	show()
	get_tree().paused = true
	refresh_display()
	inventory_opened.emit()

func close_inventory():
	is_open = false
	hide()
	get_tree().paused = false
	inventory_closed.emit()

func refresh_display():
	if not inventory_system:
		return

	for i in range(slots.size()):
		var item = inventory_system.get_item(i)
		slots[i].set_item(item)

func _on_slot_clicked(slot: InventorySlot):
	# Utilise l'item (équipe arme ou active mode placement)
	if slot.has_item() and player:
		var item = slot.get_item()
		if item:
			item.use(player, slot.slot_index)
			# Fermer l'inventaire après avoir utilisé une structure
			if item.item_type == "Structure":
				close_inventory()

func _on_item_dropped(from_slot: InventorySlot, to_slot: InventorySlot):
	if not inventory_system:
		return

	inventory_system.move_item(from_slot.slot_index, to_slot.slot_index)
	refresh_display()

func _on_slot_mouse_entered(slot: InventorySlot):
	if tooltip and slot.has_item():
		var item = slot.get_item()
		tooltip.show_tooltip(item, get_global_mouse_position())

func _on_slot_mouse_exited(_slot: InventorySlot):
	if tooltip:
		tooltip.hide_tooltip()

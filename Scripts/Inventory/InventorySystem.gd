extends Node
class_name InventorySystem

## Système d'inventaire 7x3 slots (21 slots total)

signal inventory_changed
signal item_added(item: Weapon, slot_index: int)
signal item_removed(item: Weapon, slot_index: int)
signal items_swapped(slot1: int, slot2: int)

const TOTAL_SLOTS = 21  # 7 colonnes x 3 lignes
const HOTBAR_SLOTS = 7  # Première ligne visible

var slots: Array[Weapon] = []

func _ready():
	# Initialiser tous les slots à null
	slots.resize(TOTAL_SLOTS)
	for i in range(TOTAL_SLOTS):
		slots[i] = null

## Ajoute un item dans le premier slot vide
func add_item(item: Weapon) -> bool:
	for i in range(TOTAL_SLOTS):
		if slots[i] == null:
			slots[i] = item
			item_added.emit(item, i)
			inventory_changed.emit()
			return true
	return false  # Inventaire plein

## Retire un item d'un slot spécifique
func remove_item(slot_index: int) -> Weapon:
	if slot_index < 0 or slot_index >= TOTAL_SLOTS:
		return null

	var item = slots[slot_index]
	if item:
		slots[slot_index] = null
		item_removed.emit(item, slot_index)
		inventory_changed.emit()
	return item

## Récupère l'item dans un slot
func get_item(slot_index: int) -> Weapon:
	if slot_index < 0 or slot_index >= TOTAL_SLOTS:
		return null
	return slots[slot_index]

## Place un item dans un slot spécifique
func set_item(slot_index: int, item: Weapon) -> bool:
	if slot_index < 0 or slot_index >= TOTAL_SLOTS:
		return false

	slots[slot_index] = item
	inventory_changed.emit()
	return true

## Échange deux items de slot
func swap_items(slot1: int, slot2: int):
	if slot1 < 0 or slot1 >= TOTAL_SLOTS or slot2 < 0 or slot2 >= TOTAL_SLOTS:
		return

	var temp = slots[slot1]
	slots[slot1] = slots[slot2]
	slots[slot2] = temp

	items_swapped.emit(slot1, slot2)
	inventory_changed.emit()

## Déplace un item d'un slot à un autre
func move_item(from_slot: int, to_slot: int):
	if from_slot < 0 or from_slot >= TOTAL_SLOTS or to_slot < 0 or to_slot >= TOTAL_SLOTS:
		return

	var item = slots[from_slot]
	if item == null:
		return

	# Si le slot de destination est vide
	if slots[to_slot] == null:
		slots[to_slot] = item
		slots[from_slot] = null
	else:
		# Sinon, échange les items
		swap_items(from_slot, to_slot)

	inventory_changed.emit()

## Vérifie si l'inventaire est plein
func is_full() -> bool:
	for i in range(TOTAL_SLOTS):
		if slots[i] == null:
			return false
	return true

## Compte le nombre de slots vides
func get_empty_slot_count() -> int:
	var count = 0
	for i in range(TOTAL_SLOTS):
		if slots[i] == null:
			count += 1
	return count

## Récupère tous les items de la hotbar (7 premiers slots)
func get_hotbar_items() -> Array[Weapon]:
	var hotbar: Array[Weapon] = []
	for i in range(HOTBAR_SLOTS):
		hotbar.append(slots[i])
	return hotbar

## Récupère tous les items
func get_all_items() -> Array[Weapon]:
	return slots.duplicate()

## Vide l'inventaire
func clear():
	for i in range(TOTAL_SLOTS):
		slots[i] = null
	inventory_changed.emit()

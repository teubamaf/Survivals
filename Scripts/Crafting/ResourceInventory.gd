extends Node
class_name ResourceInventory

## Système d'inventaire de ressources (bois, pierre, etc.)
## Gère le stockage et les opérations sur les ressources

## Signal émis quand une ressource change
signal resource_changed(resource_name: String, new_amount: int)
signal resource_added(resource_name: String, amount: int)
signal resource_removed(resource_name: String, amount: int)

## Stockage des ressources (nom -> quantité)
var resources: Dictionary = {}

## Capacité maximale par ressource (optionnel, -1 = illimité)
@export var max_capacity: Dictionary = {}

func _ready():
	# Initialiser les ressources de base
	initialize_resource("wood", 0)
	initialize_resource("stone", 0)
	initialize_resource("fiber", 0)  # Pour extensions futures
	initialize_resource("metal", 0)  # Pour extensions futures

## Initialise une nouvelle ressource
func initialize_resource(resource_name: String, initial_amount: int = 0):
	if not resources.has(resource_name):
		resources[resource_name] = initial_amount
		resource_changed.emit(resource_name, initial_amount)

## Ajoute une quantité de ressource
func add_resource(resource_name: String, amount: int) -> bool:
	if amount <= 0:
		return false

	# Initialise si n'existe pas
	if not resources.has(resource_name):
		initialize_resource(resource_name, 0)

	# Vérifie la capacité maximale
	if max_capacity.has(resource_name) and max_capacity[resource_name] > 0:
		var current = resources[resource_name]
		var max_cap = max_capacity[resource_name]
		if current >= max_cap:
			return false
		amount = min(amount, max_cap - current)

	resources[resource_name] += amount
	resource_added.emit(resource_name, amount)
	resource_changed.emit(resource_name, resources[resource_name])
	return true

## Retire une quantité de ressource
func remove_resource(resource_name: String, amount: int) -> bool:
	if amount <= 0:
		return false

	if not has_resource(resource_name, amount):
		return false

	resources[resource_name] -= amount
	resource_removed.emit(resource_name, amount)
	resource_changed.emit(resource_name, resources[resource_name])
	return true

## Vérifie si on a assez d'une ressource
func has_resource(resource_name: String, amount: int) -> bool:
	if not resources.has(resource_name):
		return false
	return resources[resource_name] >= amount

## Récupère la quantité d'une ressource
func get_resource(resource_name: String) -> int:
	return resources.get(resource_name, 0)

## Récupère toutes les ressources
func get_all_resources() -> Dictionary:
	return resources.duplicate()

## Définit une quantité spécifique (pour debug/cheat)
func set_resource(resource_name: String, amount: int):
	if not resources.has(resource_name):
		initialize_resource(resource_name, 0)

	resources[resource_name] = max(0, amount)
	resource_changed.emit(resource_name, resources[resource_name])

## Vérifie si on a toutes les ressources d'un dictionnaire
func has_resources(required_resources: Dictionary) -> bool:
	for resource_name in required_resources:
		if not has_resource(resource_name, required_resources[resource_name]):
			return false
	return true

## Retire plusieurs ressources en une fois (utile pour le crafting)
func remove_resources(required_resources: Dictionary) -> bool:
	# Vérifie d'abord qu'on a tout
	if not has_resources(required_resources):
		return false

	# Retire les ressources
	for resource_name in required_resources:
		remove_resource(resource_name, required_resources[resource_name])

	return true

## Affiche les ressources en console (debug)
func print_resources():
	print("=== Inventaire de Ressources ===")
	for resource_name in resources:
		print("- " + resource_name.capitalize() + ": " + str(resources[resource_name]))

extends CharacterBody2D
class_name Player

@export var max_health: int = 100
@export var current_health: int = 100
@export var speed: float = 200.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

signal health_changed(new_health: int, max_health: int)
signal weapon_equipped(weapon: Weapon)
signal weapon_unequipped
signal player_died
signal inventory_changed

var current_weapon: Weapon = null
var inventory: Array[Weapon] = []  # Ancien système, gardé pour compatibilité

# Système de crafting et ressources
var resource_inventory = null
var crafting_manager = null

# Nouveau système d'inventaire 7x3
var inventory_system: InventorySystem = null

# Système de placement de structures
var building_placer: BuildingPlacer = null

var is_dashing: bool = false
var dash_timer: Timer
var dash_cooldown_timer: Timer
var knockback_velocity: Vector2 = Vector2.ZERO
@onready var _animated_sprite = $AnimatedSprite2D
@onready var weapon_position: Node2D = $WeaponPosition

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)
	add_to_group("player")

	# Initialisation du système d'inventaire 7x3
	var InventorySystemScript = load("res://Scripts/Inventory/InventorySystem.gd")
	inventory_system = InventorySystemScript.new()
	add_child(inventory_system)
	inventory_system.inventory_changed.connect(_on_inventory_system_changed)

	# Initialisation du système de crafting
	var ResourceInventoryScript = load("res://Scripts/Crafting/ResourceInventory.gd")
	resource_inventory = ResourceInventoryScript.new()
	add_child(resource_inventory)

	var CraftingManagerScript = load("res://Scripts/Crafting/CraftingManager.gd")
	crafting_manager = CraftingManagerScript.new()
	add_child(crafting_manager)
	crafting_manager.player = self

	# Initialisation du système de placement de structures
	var BuildingPlacerScript = load("res://Scripts/Buildings/BuildingPlacer.gd")
	building_placer = BuildingPlacerScript.new()
	add_child(building_placer)

	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_finished)

	dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true

func _on_dash_finished():
	is_dashing = false

func _physics_process(delta):
	if current_health <= 0:
		_animated_sprite.play("Dead")
		return

	_handle_knockback(delta)
	_handle_enemy_separation(delta)
	_handle_input()
	_handle_movement(delta)
	_handle_weapon_rotation()
	_update_animations()

	move_and_slide()

func _handle_knockback(delta):
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)

func _handle_enemy_separation(delta):
	"""Empêche le joueur de rester collé aux ennemis"""
	var separation_force = Vector2.ZERO
	var separation_radius = 60.0  # Distance de séparation
	var separation_strength = 300.0  # Force de répulsion

	# Trouver tous les ennemis proches
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is CharacterBody2D:
			var distance = global_position.distance_to(enemy.global_position)

			# Si trop proche, appliquer une force de répulsion
			if distance < separation_radius and distance > 0:
				var push_direction = (global_position - enemy.global_position).normalized()
				var push_strength = (1.0 - distance / separation_radius) * separation_strength
				separation_force += push_direction * push_strength

	# Appliquer la force de séparation
	if separation_force.length() > 0:
		velocity += separation_force * delta

func _handle_input():
	# Tir automatique pour les armes à distance (maintien du clic)
	# Tir semi-automatique pour les armes de mêlée (clic unique)
	if current_weapon and current_weapon is WeaponRanged:
		if Input.is_action_pressed("attack"):
			_attack()
	else:
		if Input.is_action_just_pressed("attack"):
			_attack()

	if Input.is_action_just_pressed("heavy_attack"):
		_heavy_attack()

	if Input.is_action_just_pressed("reload"):
		_reload()

	if Input.is_action_just_pressed("dash"):
		_dash()

	if Input.is_action_just_pressed("switch_weapon"):
		_switch_weapon()

	if Input.is_action_just_pressed("drop_weapon"):
		_drop_weapon()

	# Menu de crafting géré par CraftingUI (touche C)

func _handle_movement(delta):
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if is_dashing:
		velocity = velocity.normalized() * dash_speed
		velocity += knockback_velocity
		return

	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * speed
	else:
		velocity = Vector2.ZERO

	velocity += knockback_velocity

func _update_animations():
	if velocity.length() > 0:
		_animated_sprite.play("walk")

		# Flip le sprite selon la direction horizontale
		if velocity.x < 0:
			_animated_sprite.flip_h = true
		elif velocity.x > 0:
			_animated_sprite.flip_h = false
	else:
		_animated_sprite.play("idle")

func _handle_weapon_rotation():
	if weapon_position and current_weapon:
		var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - global_position).normalized()

		var orbit_radius = 50.0
		var weapon_orbit_position = direction * orbit_radius
		weapon_position.position = weapon_orbit_position

		weapon_position.rotation = direction.angle()

		if direction.x < 0:
			weapon_position.scale.y = -1
		else:
			weapon_position.scale.y = 1

func _attack():
	if current_weapon:
		var mouse_position = get_global_mouse_position()
		current_weapon.use_weapon(mouse_position)

func _heavy_attack():
	if current_weapon and current_weapon is WeaponMelee:
		var mouse_position = get_global_mouse_position()
		(current_weapon as WeaponMelee).heavy_attack(mouse_position)

func _reload():
	if current_weapon and current_weapon is WeaponRanged:
		(current_weapon as WeaponRanged).reload()

func _dash():
	if _can_dash():
		is_dashing = true
		dash_timer.start()
		dash_cooldown_timer.start()

func _can_dash() -> bool:
	return dash_cooldown_timer.is_stopped()

func _switch_weapon():
	if inventory.size() > 1:
		var current_index = inventory.find(current_weapon)
		var next_index = (current_index + 1) % inventory.size()
		equip_weapon(inventory[next_index])

func equip_weapon(weapon: Weapon):
	if current_weapon:
		unequip_weapon()

	current_weapon = weapon
	weapon_position.add_child(weapon)
	weapon.position = Vector2.ZERO
	weapon_equipped.emit(weapon)

func unequip_weapon():
	if current_weapon:
		weapon_position.remove_child(current_weapon)
		current_weapon = null
		weapon_unequipped.emit()

func add_weapon_to_inventory(weapon: Weapon):
	# Crée un Item depuis l'arme
	var item = Item.from_weapon(weapon)

	# Ajoute au nouveau système d'inventaire
	if inventory_system and inventory_system.add_item(item):
		print("✓ Ajouté à l'inventaire: ", weapon.weapon_name)
		# Équipe automatiquement si aucune arme équipée
		if not current_weapon:
			equip_weapon_from_inventory(0)
	else:
		print("❌ Inventaire plein!")

	# Compatibilité ancien système
	inventory.append(weapon)
	inventory_changed.emit()

## Ajoute un item générique à l'inventaire
func add_item_to_inventory(item: Item) -> bool:
	if inventory_system and inventory_system.add_item(item):
		print("✓ Item ajouté: ", item.item_name)
		inventory_changed.emit()
		return true
	else:
		print("❌ Inventaire plein!")
		return false

func remove_weapon_from_inventory(weapon: Weapon):
	if weapon == current_weapon:
		unequip_weapon()
	inventory.erase(weapon)
	inventory_changed.emit()

func _drop_weapon():
	if current_weapon and inventory.size() > 0:
		var dropped_weapon = current_weapon
		var weapon_pickup_scene = preload("res://Scenes/WeaponPickup.tscn")

		if weapon_pickup_scene:
			var pickup = weapon_pickup_scene.instantiate()
			get_tree().current_scene.add_child(pickup)
			pickup.global_position = global_position + Vector2(50, 0)

			if dropped_weapon.weapon_scene_path != "":
				pickup.weapon_scene = load(dropped_weapon.weapon_scene_path)

			remove_weapon_from_inventory(dropped_weapon)

			if inventory.size() > 0:
				equip_weapon(inventory[0])
		else:
			print("WeaponPickup scene not found!")

func take_damage(amount: int):
	if current_health <= 0:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func apply_knockback(force: Vector2):
	knockback_velocity += force * 0.7

func _die():
	player_died.emit()
	set_physics_process(false)

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

## === SYSTÈME DE CRAFTING ===

## Affiche le menu de crafting (version console pour test)
func _show_crafting_menu():
	if not crafting_manager or not resource_inventory:
		print("Système de crafting non initialisé")
		return

	print("\n=== MENU DE CRAFTING ===")

	# Affiche les ressources
	print("\n--- Ressources disponibles ---")
	var resources = resource_inventory.get_all_resources()
	for resource_name in resources:
		print("  " + resource_name.capitalize() + ": " + str(resources[resource_name]))

	# Affiche les recettes par catégorie
	print("\n--- Recettes disponibles ---")

	var categories = ["Basic", "Combat", "Building"]
	for category in categories:
		var recipes_in_category = crafting_manager.get_recipes_by_category(category)
		if recipes_in_category.size() > 0:
			print("\n[" + category + "]")
			for recipe in recipes_in_category:
				var can_craft = recipe.can_craft(resources)
				var status = "[✓]" if can_craft else "[✗]"
				print("  " + status + " " + recipe.item_name)

				# Affiche les ressources nécessaires
				var req_text = "      Requis: "
				for res_name in recipe.required_resources:
					var needed = recipe.required_resources[res_name]
					var has = resource_inventory.get_resource(res_name)
					req_text += res_name + " " + str(has) + "/" + str(needed) + "  "
				print(req_text)

	print("\n========================")
	print("Utilisez player.craft_item('Nom Item') pour crafter")

## Fonction helper pour crafter un item par son nom
func craft_item(item_name: String) -> bool:
	if not crafting_manager or not resource_inventory:
		print("Système de crafting non initialisé")
		return false

	var recipe = crafting_manager.find_recipe_by_name(item_name)
	if not recipe:
		print("Recette introuvable: " + item_name)
		return false

	var crafted = crafting_manager.craft_item(recipe, resource_inventory, self)
	return crafted != null

## Ajoute des ressources (pour test)
func add_resources(resource_name: String, amount: int):
	if resource_inventory:
		resource_inventory.add_resource(resource_name, amount)
		print("Ajouté: " + str(amount) + " " + resource_name)

## Équipe une arme depuis le nouveau système d'inventaire
func equip_weapon_from_inventory(slot_index: int):
	if not inventory_system:
		return

	var item = inventory_system.get_item(slot_index)
	if item and item.item_type == "Weapon" and item.weapon_instance:
		equip_weapon(item.weapon_instance)

## Callback quand l'inventaire système change
func _on_inventory_system_changed():
	inventory_changed.emit()  # Émets le signal pour la hotbar

extends Node2D

## Configuration de génération
@export_group("Map Settings")
@export var map_width: int = 2000
@export var map_height: int = 2000
@export var tile_size: int = 17  # Taille des tiles de votre tilemap
@export var tilemap_scale: float = 3.0  # Scale du TileMapLayer

@export_group("Tilemap Generation")
@export var generate_ground: bool = true
@export var grass_tile_coords: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]  # Coordonnées des tiles d'herbe

@export_group("Spawn Settings")
@export var num_trees: int = 50
@export var num_rocks: int = 30
@export var num_zombies: int = 10

@export_group("Scenes")
@export var tree_scene: PackedScene
@export var rock_scene: PackedScene
@export var zombie_scene: PackedScene

@export_group("Spawn Zones")
@export var safe_zone_radius: float = 200.0  # Zone autour du joueur sans ennemis
@export var min_object_distance: float = 80.0  # Distance minimale entre les objets

var player: CharacterBody2D
var tilemap_layer: TileMapLayer
var spawned_positions: Array[Vector2] = []  # Positions des objets déjà générés

func _ready():
	# Trouver le TileMapLayer dans la scène
	tilemap_layer = get_node_or_null("../TileMapLayer")

	# Attendre un frame pour que le joueur soit bien chargé
	await get_tree().process_frame
	generate_map()

func generate_map():
	# Réinitialiser les positions générées
	spawned_positions.clear()

	# Trouver le joueur dans la scène
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("MapGenerator: Aucun joueur trouvé dans le groupe 'player'")

	# Générer le sol d'herbe
	if generate_ground and tilemap_layer != null:
		generate_ground_tiles()
	elif generate_ground and tilemap_layer == null:
		push_warning("MapGenerator: TileMapLayer non trouvé, impossible de générer le sol")

	# Générer les éléments de la map
	spawn_objects(tree_scene, num_trees, "Trees")
	spawn_objects(rock_scene, num_rocks, "Rocks")
	spawn_zombies()

	print("Map générée avec succès!")
	print("- Sol généré: ", generate_ground and tilemap_layer != null)
	print("- Arbres: ", num_trees)
	print("- Rochers: ", num_rocks)
	print("- Zombies: ", num_zombies)

func generate_ground_tiles():
	if grass_tile_coords.is_empty():
		push_warning("MapGenerator: Aucune tile d'herbe configurée")
		return

	# Calculer le nombre de tiles nécessaires en fonction de la taille de la map et du scale
	var scaled_tile_size = tile_size * tilemap_scale
	var tiles_x = int(map_width / scaled_tile_size) + 2
	var tiles_y = int(map_height / scaled_tile_size) + 2

	var start_x: int = -tiles_x / 2
	var start_y: int = -tiles_y / 2

	print("Génération du sol: ", tiles_x, "x", tiles_y, " tiles")

	# Placer les tiles d'herbe de manière aléatoire
	for x in range(tiles_x):
		for y in range(tiles_y):
			var tile_pos = Vector2i(start_x + x, start_y + y)
			var tile_coord = grass_tile_coords[randi() % grass_tile_coords.size()]
			tilemap_layer.set_cell(tile_pos, 0, tile_coord)

func spawn_objects(scene: PackedScene, count: int, parent_name: String):
	if scene == null:
		push_warning("MapGenerator: Scene manquante pour " + parent_name)
		return

	# Créer un conteneur pour organiser la scène
	var container = Node2D.new()
	container.name = parent_name
	add_child(container)

	var spawned = 0
	var max_attempts = count * 20  # Plus de tentatives pour trouver une bonne position
	var attempts = 0

	while spawned < count and attempts < max_attempts:
		var spawn_pos = get_random_position()

		# Vérifier que la position n'est pas trop proche des autres objets
		if is_position_valid(spawn_pos):
			var instance = scene.instantiate()
			instance.position = spawn_pos
			container.add_child(instance)
			spawned_positions.append(spawn_pos)
			spawned += 1

		attempts += 1

	if spawned < count:
		print("Attention: Seulement ", spawned, "/", count, " ", parent_name, " ont pu être placés")

func spawn_zombies():
	if zombie_scene == null:
		push_warning("MapGenerator: Scene de zombie manquante")
		return

	# Créer un conteneur pour les zombies
	var container = Node2D.new()
	container.name = "Zombies"
	add_child(container)

	var spawned = 0
	var max_attempts = num_zombies * 20
	var attempts = 0

	while spawned < num_zombies and attempts < max_attempts:
		var spawn_pos = get_random_position()

		# Vérifier que le zombie n'est pas trop proche du joueur
		if player != null:
			var distance_to_player = spawn_pos.distance_to(player.global_position)
			if distance_to_player < safe_zone_radius:
				attempts += 1
				continue

		# Vérifier que la position n'est pas trop proche des autres objets
		if is_position_valid(spawn_pos):
			var instance = zombie_scene.instantiate()
			instance.position = spawn_pos
			container.add_child(instance)
			spawned_positions.append(spawn_pos)
			spawned += 1

		attempts += 1

	if spawned < num_zombies:
		print("Attention: Seulement ", spawned, "/", num_zombies, " zombies ont pu être placés")

func get_random_position() -> Vector2:
	var x = randf_range(-map_width / 2.0, map_width / 2.0)
	var y = randf_range(-map_height / 2.0, map_height / 2.0)
	return Vector2(x, y)

func is_position_valid(pos: Vector2) -> bool:
	# Vérifier que la position n'est pas trop proche des objets déjà placés
	for spawned_pos in spawned_positions:
		if pos.distance_to(spawned_pos) < min_object_distance:
			return false
	return true

# Fonction pour régénérer la map (utile pour le debug)
func regenerate_map():
	# Supprimer tous les objets générés
	for child in get_children():
		child.queue_free()

	# Régénérer
	await get_tree().process_frame
	generate_map()

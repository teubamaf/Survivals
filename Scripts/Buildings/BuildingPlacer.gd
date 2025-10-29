extends Node
class_name BuildingPlacer

## Système de placement de structures

signal building_placed(structure: PlaceableStructure)
signal building_cancelled

var player: Player
var current_preview: PlaceableStructure = null
var is_placing: bool = false
var rotation_angle: float = 0.0
var snap_to_walls: bool = true

const ROTATION_STEP = PI / 2  # 90 degrés
const GRID_SIZE = 16

func _ready():
	player = get_tree().get_first_node_in_group("player")

func start_placing(structure_scene: PackedScene):
	"""Commence le placement d'une structure"""
	if is_placing:
		cancel_placement()

	current_preview = structure_scene.instantiate()
	if not current_preview is PlaceableStructure:
		current_preview.queue_free()
		return

	get_tree().current_scene.add_child(current_preview)
	current_preview.is_placed = false
	is_placing = true
	rotation_angle = 0.0

func _process(_delta):
	if not is_placing or not current_preview:
		return

	# Positionner la preview à la souris
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_2d()
	if camera:
		mouse_pos = camera.get_global_mouse_position()
	else:
		mouse_pos = get_tree().root.get_mouse_position()

	# Snap à la grille
	mouse_pos = _snap_to_grid(mouse_pos)

	# Snap aux murs proches
	if snap_to_walls:
		mouse_pos = _snap_to_nearby_walls(mouse_pos)

	current_preview.global_position = mouse_pos
	current_preview.rotation = rotation_angle

func _input(event):
	if not is_placing:
		return

	# Rotation avec R
	if event.is_action_pressed("rotate_building"):
		rotate_preview()

	# Placer avec clic gauche
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("attack"):
		place_building()

	# Annuler avec clic droit ou Echap
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("heavy_attack"):
		cancel_placement()

func rotate_preview():
	"""Tourne la preview de 90 degrés"""
	rotation_angle += ROTATION_STEP
	if rotation_angle >= PI * 2:
		rotation_angle = 0

func place_building():
	"""Place la structure définitivement"""
	if not current_preview:
		return

	if current_preview.can_place_here():
		current_preview.place()
		building_placed.emit(current_preview)
		print("✓ Structure placée: " + current_preview.structure_name)
		current_preview = null
		is_placing = false
	else:
		print("❌ Impossible de placer ici")

func cancel_placement():
	"""Annule le placement"""
	if current_preview:
		current_preview.queue_free()
		current_preview = null
	is_placing = false
	building_cancelled.emit()
	print("Placement annulé")

func _snap_to_grid(pos: Vector2) -> Vector2:
	"""Snap la position à une grille"""
	return Vector2(
		round(pos.x / GRID_SIZE) * GRID_SIZE,
		round(pos.y / GRID_SIZE) * GRID_SIZE
	)

func _snap_to_nearby_walls(pos: Vector2) -> Vector2:
	"""Snap aux murs proches"""
	if not current_preview:
		return pos

	var nearest_wall = _find_nearest_wall(pos)
	if not nearest_wall:
		return pos

	var distance = pos.distance_to(nearest_wall.global_position)
	if distance > current_preview.snap_distance:
		return pos

	# Calcule la position snappée selon l'orientation du mur
	var wall_angle = nearest_wall.rotation
	var offset = Vector2(current_preview.snap_distance, 0).rotated(wall_angle)

	return nearest_wall.global_position + offset

func _find_nearest_wall(pos: Vector2) -> PlaceableStructure:
	"""Trouve le mur le plus proche"""
	var nearest: PlaceableStructure = null
	var min_distance = INF

	for node in get_tree().get_nodes_in_group("structures"):
		if node is PlaceableStructure and node.is_placed:
			var dist = pos.distance_to(node.global_position)
			if dist < min_distance:
				min_distance = dist
				nearest = node

	return nearest

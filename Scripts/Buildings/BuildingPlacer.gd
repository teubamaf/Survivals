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
var can_place: bool = false
var snap_to_line: bool = false  # Snap horizontal/vertical activé avec Shift

# Pour décrémenter l'item après placement
var current_structure_scene: PackedScene = null
var item_slot_index: int = -1
var first_placement_pos: Vector2 = Vector2.ZERO  # Position du premier placement pour le snap

const ROTATION_STEP = PI / 2  # 90 degrés
const GRID_SIZE = 16
const MAX_PLACEMENT_RANGE = 150.0  # Portée maximum pour placer les constructions
const LINE_SNAP_THRESHOLD = 32.0  # Distance pour activer le snap de ligne

func _ready():
	player = get_tree().get_first_node_in_group("player")

func start_placing(structure_scene: PackedScene):
	"""Commence le placement d'une structure (ancienne méthode sans décrémentation)"""
	start_placing_with_decrement(structure_scene, null, -1)

func start_placing_with_decrement(structure_scene: PackedScene, target_player: Player = null, slot_index: int = -1):
	"""Commence le placement d'une structure avec décrémentation de l'item"""
	if is_placing:
		cancel_placement()

	current_structure_scene = structure_scene
	item_slot_index = slot_index
	if target_player:
		player = target_player

	current_preview = structure_scene.instantiate()
	if not current_preview is PlaceableStructure:
		current_preview.queue_free()
		return

	get_tree().current_scene.add_child(current_preview)
	current_preview.is_placed = false
	is_placing = true
	rotation_angle = 0.0

func _process(_delta):
	if not is_placing or not current_preview or not player:
		return

	# Vérifier si Shift est pressé pour le snap de ligne
	snap_to_line = Input.is_key_pressed(KEY_SHIFT)

	# Positionner la preview à la souris
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_2d()
	if camera:
		mouse_pos = camera.get_global_mouse_position()
	else:
		mouse_pos = get_tree().root.get_mouse_position()

	# Snap à la grille
	mouse_pos = _snap_to_grid(mouse_pos)

	# Snap horizontal/vertical si Shift est pressé
	if snap_to_line and first_placement_pos != Vector2.ZERO:
		mouse_pos = _snap_to_horizontal_vertical(mouse_pos, first_placement_pos)

	# Snap aux murs proches (si pas de snap de ligne actif)
	if snap_to_walls and not snap_to_line:
		mouse_pos = _snap_to_nearby_walls(mouse_pos)

	current_preview.global_position = mouse_pos
	current_preview.rotation = rotation_angle

	# Vérifier la portée de placement
	var distance_to_player = player.global_position.distance_to(mouse_pos)
	can_place = distance_to_player <= MAX_PLACEMENT_RANGE

	# Changer la couleur de la preview selon la portée et le mode
	if not can_place:
		current_preview.modulate = Color(1, 0.3, 0.3, 0.7)  # Rouge transparent (trop loin)
	elif snap_to_line:
		current_preview.modulate = Color(0.3, 1, 0.3, 0.7)  # Vert transparent (snap de ligne actif)
	else:
		current_preview.modulate = Color(1, 1, 1, 0.7)  # Blanc transparent (peut placer)

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

	if not can_place:
		print("❌ Trop loin pour placer")
		_play_error_sound()
		return

	if current_preview.can_place_here():
		current_preview.modulate = Color(1, 1, 1, 1)  # Remettre la couleur normale
		var placement_position = current_preview.global_position
		current_preview.place()
		building_placed.emit(current_preview)
		print("✓ Structure placée: " + current_preview.structure_name)

		# Feedback visuel et sonore
		_play_placement_effects(placement_position)

		# Sauvegarder la position pour le snap de ligne
		if first_placement_pos == Vector2.ZERO:
			first_placement_pos = placement_position

		# Décrémenter la quantité de l'item dans l'inventaire
		if player and player.inventory_system and item_slot_index >= 0:
			var item = player.inventory_system.get_item(item_slot_index)
			if item and item.quantity > 0:
				item.quantity -= 1
				if item.quantity <= 0:
					# Retirer l'item de l'inventaire s'il n'en reste plus
					player.inventory_system.remove_item(item_slot_index)
					# Réinitialiser pour la prochaine fois
					current_preview = null
					is_placing = false
					item_slot_index = -1
					first_placement_pos = Vector2.ZERO
				else:
					# Forcer la mise à jour de l'UI
					player.inventory_system.inventory_changed.emit()
					# Créer une nouvelle preview pour continuer à placer
					current_preview = current_structure_scene.instantiate()
					get_tree().current_scene.add_child(current_preview)
					current_preview.is_placed = false
			else:
				current_preview = null
				is_placing = false
				item_slot_index = -1
				first_placement_pos = Vector2.ZERO
		else:
			current_preview = null
			is_placing = false
			first_placement_pos = Vector2.ZERO
	else:
		print("❌ Impossible de placer ici")
		_play_error_sound()

func cancel_placement():
	"""Annule le placement"""
	if current_preview:
		current_preview.queue_free()
		current_preview = null
	is_placing = false
	first_placement_pos = Vector2.ZERO
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

func _snap_to_horizontal_vertical(pos: Vector2, reference_pos: Vector2) -> Vector2:
	"""Snap la position pour être horizontale ou verticale par rapport à la référence"""
	var delta = pos - reference_pos

	# Déterminer si on snap horizontalement ou verticalement
	if abs(delta.x) > abs(delta.y):
		# Snap horizontal (même Y que la référence)
		return Vector2(pos.x, reference_pos.y)
	else:
		# Snap vertical (même X que la référence)
		return Vector2(reference_pos.x, pos.y)

func _play_placement_effects(position: Vector2):
	"""Joue les effets visuels et sonores lors du placement"""
	# Créer des particules de placement
	_create_placement_particles(position)

	# Jouer un son de placement (si disponible)
	_play_placement_sound()

func _create_placement_particles(position: Vector2):
	"""Crée des particules visuelles au moment du placement"""
	# Créer plusieurs particules pour un effet de construction
	for i in range(8):
		var particle = Sprite2D.new()
		particle.modulate = Color(0.8, 0.6, 0.3)  # Couleur bois
		particle.z_index = 10

		# Créer une petite texture carrée
		var image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		var texture = ImageTexture.create_from_image(image)
		particle.texture = texture

		get_tree().current_scene.add_child(particle)
		particle.global_position = position

		# Animation de particule
		var angle = (i / 8.0) * TAU
		var velocity = Vector2(cos(angle), sin(angle)) * 50

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", position + velocity, 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.tween_property(particle, "scale", Vector2.ZERO, 0.5)
		tween.finished.connect(particle.queue_free)

func _play_placement_sound():
	"""Joue le son de placement (si disponible)"""
	# Vérifier si un fichier audio existe
	var sound_path = "res://Assets/Sounds/build_place.wav"
	if not ResourceLoader.exists(sound_path):
		sound_path = "res://Assets/Sounds/build_place.ogg"

	if ResourceLoader.exists(sound_path):
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.stream = load(sound_path)
		audio_player.volume_db = -5
		get_tree().current_scene.add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
	# Sinon, pas de son (silencieux)

func _play_error_sound():
	"""Joue le son d'erreur (si disponible)"""
	var sound_path = "res://Assets/Sounds/build_error.wav"
	if not ResourceLoader.exists(sound_path):
		sound_path = "res://Assets/Sounds/build_error.ogg"

	if ResourceLoader.exists(sound_path):
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.stream = load(sound_path)
		audio_player.volume_db = -3
		get_tree().current_scene.add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)

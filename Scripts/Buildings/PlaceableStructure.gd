extends StaticBody2D
class_name PlaceableStructure

## Structure plaçable par le joueur (mur, barricade, etc.)

signal structure_destroyed

@export var structure_name: String = "Structure"
@export var snap_distance: float = 32.0  # Distance pour le snap
@export var max_health: int = 100
@export var current_health: int = 100

var is_placed: bool = false

func _ready():
	if not is_placed:
		# Mode preview avant placement
		modulate = Color(1, 1, 1, 0.5)
		collision_layer = 0  # Pas de collision en preview
	else:
		# Structure placée
		modulate = Color(1, 1, 1, 1)
		collision_layer = 1

func place():
	"""Confirme le placement de la structure"""
	is_placed = true
	modulate = Color(1, 1, 1, 1)
	collision_layer = 1
	collision_mask = 1

func can_place_here() -> bool:
	"""Vérifie si on peut placer la structure ici"""
	# À implémenter : vérifier collision avec autres structures
	return true

func take_damage(amount: int):
	"""Reçoit des dégâts"""
	if not is_placed:
		return

	current_health -= amount

	# Effet visuel de dégâts
	_play_damage_effect()

	if current_health <= 0:
		_destroy()

func _play_damage_effect():
	"""Effet visuel quand la structure prend des dégâts"""
	# Flash rouge
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

func _destroy():
	"""Détruit la structure"""
	print("Structure détruite: " + structure_name)
	structure_destroyed.emit()
	queue_free()

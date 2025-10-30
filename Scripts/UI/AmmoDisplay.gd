extends Control
class_name AmmoDisplay

## Affichage des munitions en bas à droite de l'écran

@onready var ammo_label: Label = $Panel/MarginContainer/VBoxContainer/AmmoLabel
@onready var weapon_name_label: Label = $Panel/MarginContainer/VBoxContainer/WeaponName

var player: Player = null
var current_weapon: WeaponRanged = null

func _ready():
	# Se positionner en bas à droite
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	offset_left = -200
	offset_top = -100
	offset_right = -20
	offset_bottom = -20

	# Trouver le joueur
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.weapon_equipped.connect(_on_weapon_equipped)
		player.weapon_unequipped.connect(_on_weapon_unequipped)

	hide()  # Cache par défaut

func _on_weapon_equipped(weapon: Weapon):
	# Vérifier si c'est une arme à distance
	if weapon is WeaponRanged:
		current_weapon = weapon as WeaponRanged

		# Se connecter aux signaux de l'arme
		if not current_weapon.weapon_used.is_connected(_update_ammo_display):
			current_weapon.weapon_used.connect(_update_ammo_display)
		if not current_weapon.reload_started.is_connected(_on_reload_started):
			current_weapon.reload_started.connect(_on_reload_started)
		if not current_weapon.reload_finished.is_connected(_on_reload_finished):
			current_weapon.reload_finished.connect(_on_reload_finished)

		_update_ammo_display()
		show()
	else:
		# Arme de mêlée, cache l'affichage
		current_weapon = null
		hide()

func _on_weapon_unequipped():
	current_weapon = null
	hide()

func _update_ammo_display():
	if not current_weapon:
		return

	if weapon_name_label:
		weapon_name_label.text = current_weapon.weapon_name

	if ammo_label:
		var ammo_text = str(current_weapon.ammunition) + " / " + str(current_weapon.max_ammunition)
		ammo_label.text = ammo_text

		# Changer la couleur selon les munitions restantes
		var ammo_percent = current_weapon.get_ammunition_percent()
		if ammo_percent <= 0.0:
			ammo_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # Rouge
		elif ammo_percent <= 0.3:
			ammo_label.add_theme_color_override("font_color", Color(1, 0.7, 0.2))  # Orange
		else:
			ammo_label.add_theme_color_override("font_color", Color.WHITE)

func _on_reload_started():
	if ammo_label:
		ammo_label.text = "RECHARGING..."
		ammo_label.add_theme_color_override("font_color", Color(0.5, 0.5, 1))  # Bleu

func _on_reload_finished():
	_update_ammo_display()

func _process(_delta):
	# Mise à jour continue pour s'assurer que l'affichage est à jour
	if current_weapon and visible:
		_update_ammo_display()

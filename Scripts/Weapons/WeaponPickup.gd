extends Area2D
class_name WeaponPickup

@export var weapon_scene: PackedScene
@export var weapon_name: String = "Unknown Weapon"
@export var auto_pickup: bool = false

signal pickup_available(weapon_pickup: WeaponPickup)
signal pickup_unavailable(weapon_pickup: WeaponPickup)
signal weapon_picked_up(weapon: Weapon, player: Player)

var player_in_range: Player = null
var pickup_label: Label
var sprite: Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_setup_weapon_display()

	pickup_label = Label.new()
	add_child(pickup_label)
	pickup_label.text = "[E] " + weapon_name
	pickup_label.position = Vector2(-50, -40)
	pickup_label.visible = false

func _setup_weapon_display():
	if not weapon_scene:
		return

	var weapon_instance = weapon_scene.instantiate()
	if weapon_instance and weapon_instance is Weapon:
		weapon_name = weapon_instance.weapon_name

		var weapon_sprite = weapon_instance.get_node("Sprite2D")
		if weapon_sprite and weapon_sprite is Sprite2D:
			sprite = get_node("Sprite2D")
			if sprite:
				sprite.texture = weapon_sprite.texture
				sprite.scale = weapon_sprite.scale * 0.7

	weapon_instance.queue_free()

func _on_body_entered(body: Node2D):
	if body is Player:
		player_in_range = body
		pickup_label.visible = true
		pickup_available.emit(self)

		if auto_pickup:
			_pickup_weapon()

func _on_body_exited(body: Node2D):
	if body is Player and body == player_in_range:
		player_in_range = null
		pickup_label.visible = false
		pickup_unavailable.emit(self)

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		_pickup_weapon()

func _pickup_weapon():
	if not weapon_scene or not player_in_range:
		return

	var weapon = weapon_scene.instantiate()

	if weapon is Weapon:
		player_in_range.add_weapon_to_inventory(weapon)
		weapon_picked_up.emit(weapon, player_in_range)
		queue_free()
	else:
		print("Error: weapon_scene is not a Weapon!")
		weapon.queue_free()

func can_pickup() -> bool:
	return player_in_range != null

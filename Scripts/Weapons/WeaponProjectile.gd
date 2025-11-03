extends Area2D
class_name WeaponProjectile

@export var damage: int = 50
@export var speed: float = 500.0
@export var max_distance: float = 1000.0
@export var lifetime: float = 5.0

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var start_position: Vector2
var owner_node: Node2D
var distance_traveled: float = 0.0
var can_collide_with_obstacles: bool = false  # Empêche collision immédiate
var is_initialized: bool = false  # Pour initialiser start_position au bon moment

signal projectile_hit(target: Node2D, damage: int)

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Activer les collisions avec obstacles après un court délai
	var collision_delay_timer = Timer.new()
	add_child(collision_delay_timer)
	collision_delay_timer.wait_time = 0.05  # 50ms de délai
	collision_delay_timer.one_shot = true
	collision_delay_timer.timeout.connect(func(): can_collide_with_obstacles = true)
	collision_delay_timer.start()

	var lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_destroy_projectile)
	lifetime_timer.start()

func _physics_process(delta):
	# Initialiser start_position au premier frame après que la position soit définie
	if not is_initialized:
		start_position = global_position
		is_initialized = true

	global_position += velocity * delta
	distance_traveled = start_position.distance_to(global_position)

	if distance_traveled >= max_distance:
		_destroy_projectile()

func set_velocity(new_velocity: Vector2):
	velocity = new_velocity
	direction = velocity.normalized()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	velocity = direction * speed

func set_speed(new_speed: float):
	speed = new_speed
	if direction != Vector2.ZERO:
		velocity = direction * speed

func set_damage(new_damage: int):
	damage = new_damage

func set_owner_node(node: Node2D):
	owner_node = node

func _on_body_entered(body: Node2D):
	if body == owner_node:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		projectile_hit.emit(body, damage)
		_destroy_projectile()
	# Se détruit seulement sur les vrais obstacles (murs, structures)
	# Pas sur les ressources destructibles (arbres, rochers sur layer 3)
	# Et seulement après le délai initial pour éviter collision immédiate
	elif can_collide_with_obstacles and body.collision_layer == 1:  # Obstacles fixes uniquement
		_destroy_projectile()

func _on_area_entered(area: Area2D):
	if area == owner_node:
		return

	if area.has_method("take_damage"):
		area.take_damage(damage)
		projectile_hit.emit(area, damage)
		_destroy_projectile()

func _destroy_projectile():
	queue_free()

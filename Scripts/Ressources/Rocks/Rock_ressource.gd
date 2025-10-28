extends Area2D

@onready var label: Label = $Label_Number

func _ready():
	body_entered.connect(_on_body_entered)

func set_log_amount(amount: int):
	label.text = str(amount)

func _on_body_entered(body):
	if body is Player:
		# Ajoute la pierre à l'inventaire de ressources du joueur
		var rock_amount = int(label.text)
		if body.resource_inventory:
			body.resource_inventory.add_resource("stone", rock_amount)
			print("Ramassé ", rock_amount, " pierres (Total: ", body.resource_inventory.get_resource("stone"), ")")
		queue_free()

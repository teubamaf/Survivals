extends Area2D

@onready var label: Label = $Label_Number

func _ready():
	body_entered.connect(_on_body_entered)

func set_log_amount(amount: int):
	label.text = str(amount)

func _on_body_entered(body):
	if body is Player:
		# Ajoute le bois à l'inventaire de ressources du joueur
		var log_amount = int(label.text)
		if body.resource_inventory:
			body.resource_inventory.add_resource("wood", log_amount)
			print("Ramassé ", log_amount, " bûches (Total: ", body.resource_inventory.get_resource("wood"), ")")
		queue_free()

extends Area2D

@onready var label: Label = $Label_Number

func _ready():
	body_entered.connect(_on_body_entered)

func set_log_amount(amount: int):
	label.text = str(amount)

func _on_body_entered(body):
	if body is Player:
		# Logique pour ajouter les logs à l'inventaire du joueur
		var log_amount = int(label.text)
		print("Ramassé ", log_amount, " bûches")
		queue_free()

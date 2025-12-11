extends Area2D

func _ready() -> void:
	body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body):
	print("Encostou:", body)
	if body.is_in_group("Player"):
		body.morrer()

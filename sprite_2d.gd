extends Sprite2D


var rotation_speed: float = deg_to_rad(3000.0)

func _process(delta: float):
	rotation += rotation_speed * delta

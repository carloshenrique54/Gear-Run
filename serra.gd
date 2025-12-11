extends RigidBody2D
var move = 1
@export var ponto_a: Vector2
@export var ponto_b: Vector2
@export var velocidade: float = 200.0

func _ready() -> void:
	freeze_mode = RigidBody2D.FreezeMode.FREEZE_MODE_STATIC
	freeze = true
	$Area2D.body_entered.connect(_on_hitbox_body_entered)

var indo_para_b = true

func _process(delta):
	var destino = ponto_b if indo_para_b else ponto_a
	global_position = global_position.move_toward(destino, velocidade * delta)

	if global_position.distance_to(destino) < 1.0:
		indo_para_b = !indo_para_b
	
func _on_hitbox_body_entered(body):
	print("Encostou:", body)
	if body.is_in_group("Player"):
		body.morrer()

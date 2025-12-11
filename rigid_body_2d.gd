extends RigidBody2D

@export var cair_delay: float  = 1.0
@export var voltar_delay: float = 3.0

var voltando: bool = false
var posicao_original: Vector2	
var provoca_queda: bool = false

func _ready() -> void:
	posicao_original = global_position
	freeze_mode = RigidBody2D.FreezeMode.FREEZE_MODE_STATIC
	freeze = true
	$Timer.wait_time = cair_delay
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if provoca_queda or not body.is_in_group("Player"):
		return
	provoca_queda = true
	$Timer.start()

func _on_timer_timeout() -> void:
	freeze = false
	$CollisionShape2D.disabled = true
	
func _physics_process(_delta: float) -> void:
	if global_position.y > 2000 and not voltando:
		voltando_original()

func voltando_original():
	voltando = true
	
	provoca_queda = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicao_original, voltar_delay).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	voltando = false
	freeze = true
	$Timer.stop()
	$CollisionShape2D.disabled = false
	print("Plataforma retornou à origem.")

extends CharacterBody2D

# ============================================================
# CONSTANTES (FINAL: PULO E GRAVIDADE)
# ============================================================
const SPEED = 275               
const JUMP_FORCE = -480         
const SECOND_JUMP_FORCE = -350  
const WALL_JUMP_VERTICAL_FORCE = -400 
const WALL_JUMP_PUSH = 500      
const WALL_SLIDE_SPEED = 60
var andar = false     
var gravity = 1500              

# NOVAS CONSTANTES PARA FLUIDEZ
const ACCEL = 1800              
const FRICTION = 2500           

var jumps = 1                   
var max_jumps = 1               

# ============================================================
# DASH (AJUSTADO PARA SER MAIS CURTO E CONTROLADO)
# ============================================================
@export var DASH_SPEED := 500   
@export var DASH_TIME := 0.10   
@export var DASH_COOLDOWN := 0.4 

var has_air_dash = true

# NOVO: Variável para a Atualização do Dash (Manto Sombrio)
var has_shade_cloak = false 

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var dash_dir := Vector2.ZERO

# ============================================================
# ANIMAÇÕES
# ============================================================
@onready var anim = $spr_player
@onready var collision_shape = $col_player
var facing = 1

# ============================================================
# SQUASH & STRETCH (SUAVE)
# ============================================================
var default_scale := Vector2(1, 1)

func _process(delta):
	squash_and_stretch(delta)


func squash_and_stretch(delta):
	var spd: float = abs(velocity.x)

	var target_x = 1.0
	var target_y = 1.0

	if is_dashing:
		target_x = 1.18
		target_y = 0.90

	elif not is_on_floor():
		if velocity.y < 0:      # Subindo
			target_x = 0.97
			target_y = 1.08
		else:                    # Caindo
			target_x = 1.03
			target_y = 0.97

	else:
		if spd > 10:
			# Esticamento sutil ao andar
			target_x = 1.02
			target_y = 0.98
		else:
			target_x = 1.0
			target_y = 1.0

	# Suavização
	$spr_player.scale.x = lerp($spr_player.scale.x, target_x, delta * 8)
	$spr_player.scale.y = lerp($spr_player.scale.y, target_y, delta * 8)

# ============================================================
# FÍSICA
# ============================================================
func _physics_process(delta):
	var move = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Resetar no chão
	if is_on_floor():
		jumps = max_jumps
		has_air_dash = true 
		if dash_cooldown > 0:
			dash_cooldown -= delta

	# ======================================
	# CONTROLE DE DASH
	# ======================================
	var can_dash = dash_cooldown <= 0 and (is_on_floor() or has_air_dash)

	if Input.is_action_just_pressed("dash") and can_dash:
		var final_dir = Vector2(move, 0).normalized()
		if final_dir.x == 0:
			final_dir.x = facing

		is_dashing = true
		dash_timer = DASH_TIME
		dash_dir = final_dir
		has_air_dash = false
		
		# INÍCIO DO MANTO SOMBRIO: Torna invencível ao desativar a colisão
		if has_shade_cloak and collision_shape:
			collision_shape.set_deferred("disabled", true)
		
	# ======================================
	# DASH ATIVO
	# ======================================
	if is_dashing:
		velocity.x = dash_dir.x * DASH_SPEED
		velocity.y = 0

		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown = DASH_COOLDOWN
			velocity.y += gravity * delta
			
			# FIM DO MANTO SOMBRIO: Reativa a colisão
			if has_shade_cloak and collision_shape:
				collision_shape.set_deferred("disabled", false)
			
	# ======================================
	# MOVIMENTO NORMAL
	# ======================================
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		# PULO VARIÁVEL / JUMP CUT
		if velocity.y < 0 and Input.is_action_just_released("ui_pular"):
			velocity.y *= 0.3 

		if Input.is_action_just_pressed("ui_andar"):
			andar = true
			print(andar)

		if Input.is_action_just_released("ui_andar"):
			andar = false
			print(andar)

		# MOVIMENTO HORIZONTAL COM ACELERAÇÃO E FRICÇÃO
		if move != 0 and andar == false:
			velocity.x = move_toward(velocity.x, move * SPEED, ACCEL * delta)
		elif move != 0 and andar == true:
			velocity.x = move_toward(velocity.x, move * (SPEED-150), ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
		# WALL SLIDE
		if is_on_wall() and not is_on_floor() and velocity.y > 0:
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		# ANIMAÇÕES
		if move != 0 and andar == false:
			facing = sign(move)
			anim.play("walk_direita" if facing == 1 else "walk_esquerda")
			anim.sprite_frames.set_animation_speed("walk_direita" if facing == 1 else "walk_esquerda", 5)
		elif move != 0 and andar == true:
			facing = sign(move)
			anim.play("walk_direita" if facing == 1 else "walk_esquerda")
			anim.sprite_frames.set_animation_speed("walk_direita" if facing == 1 else "walk_esquerda", 2.5)
		if move == 0 and is_on_floor():
			$spr_player.position.y = -2
			anim.play("idle_direita" if facing == 1 else "idle_esquerda")

		elif not is_on_floor() and not is_on_wall():
			anim.play("jump_direita" if facing == 1 else "jump_esquerda")

		elif is_on_wall():
			anim.play("hold_direita" if facing == 1 else "hold_esquerda")

		# PULO
		if Input.is_action_just_pressed("ui_pular"):
			if is_on_floor():
				jump(JUMP_FORCE)
			# WALL JUMP SÓ PERMITIDO SE ESTIVER DESCENDO/PARADO (velocity.y >= 0)
			elif is_on_wall() and velocity.y >= 0: 
				wall_jump() 
			elif jumps > 0:
				jump(SECOND_JUMP_FORCE)
				jumps -= 1

	move_and_slide()

	# ======================================
	# COLISÃO COM "KILLER"
	# ======================================

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================
func jump(force):
	velocity.y = force

func wall_jump():
	velocity.y = WALL_JUMP_VERTICAL_FORCE 
	
	var wall_dir = 0
	if is_on_wall_only():
		wall_dir = get_last_slide_collision().get_normal().x
	
	velocity.x = -wall_dir * WALL_JUMP_PUSH
	
	facing = sign(velocity.x)

func morrer():
	print("Player morreu!")

	var morte_screen = get_tree().current_scene.get_node("Morte/MorteMenu")
	morte_screen.visible = true
	get_tree().paused = true

	queue_free()

extends CharacterBody2D

const SPEED = 180
const JUMP_FORCE = -300
const WALL_JUMP_PUSH = 200
const WALL_SLIDE_SPEED = 60
var gravity = 900

@onready var anim = $spr_player
# 1 = direita | -1 = esquerda
var facing = 1

func _physics_process(delta):
	var move = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = move * SPEED

	if move != 0:
		facing = sign(move)
		if facing == 1:
			anim.play("walk_direita")
		else:
			anim.play("walk_esquerda")

	if move == 0 and is_on_floor() == true:
		if facing == 1:
			anim.play("idle_direita")
		else:
			anim.play("idle_esquerda")
	elif not is_on_floor() and not is_on_wall():
		if facing == 1:
			anim.play("jump_direita")
		else:
			anim.play("jump_esquerda")
	elif is_on_wall():
		if facing == 1:
			anim.play("hold_direita")
		else:
			anim.play("hold_esquerda")

	if Input.is_action_just_pressed("ui_pular") and is_on_floor():
		velocity.y = JUMP_FORCE
		print(move)

	if is_on_wall() and velocity.y > 0 and not is_on_floor():
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

	# Wall jump
	if Input.is_action_just_pressed("ui_pular") and is_on_wall() and not is_on_floor():
		wall_jump(move)
	
	move_and_slide()

func wall_jump(input_dir):
	velocity.y = JUMP_FORCE
	if input_dir < 0: # encostado na esquerda
		velocity.x = WALL_JUMP_PUSH
	elif input_dir > 0: # encostado na direita
		velocity.x = -WALL_JUMP_PUSH

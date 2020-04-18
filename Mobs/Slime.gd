# Created by sh1n24

extends KinematicBody2D

const FLOOR_NORMAL = Vector2(0, -1)
enum { PINK, BLUE }
enum { IDLE, TAKEOFF, JUMP, NONE }

export var type = PINK
export var player_spawn : Vector2 = Vector2.ZERO	# Player spawn point when touches
export var spawn_point : Vector2 = Vector2.ZERO	# Point of respawn
export var gravity = 450.0
export var max_speed = Vector2(90, 500)
export var jump_force = Vector2(60, -80)
export var assault_force = Vector2(90, -100)
export var take_off_duration = 0.15

var target : Player
var state = IDLE
var direction = 0
var velocity = Vector2.ZERO
var state_duration = 1.0	# Last time of current state
var take_off_time = 0

onready var ground_check_left = $GroundCheckLeft
onready var ground_check_right = $GroundCheckRight
onready var wall_check_left = $WallCheckLeft
onready var wall_check_right = $WallCheckRight
onready var animation = $AnimationPlayer
var sprite : AnimatedSprite

func _ready():
	state_duration = rand_range(0.8, 1.5)
	if spawn_point == Vector2.ZERO:
		spawn_point = Vector2(global_position)
	if type == PINK:
		sprite = $PinkSprite
		$BlueSprite.hide()
	else:
		sprite = $BlueSprite
		$PinkSprite.hide()

func _physics_process(delta):
	if state == NONE:
		return
	if state == IDLE:
		state_duration -= delta
		if target != null:
			state_duration = 0
		if state_duration <= 0:
			# Idle state finished, ready to jump
			state = TAKEOFF
			state_duration = 0.2
			if target == null:
				direction = 1 if randf() < 0.5 else -1
	if state == TAKEOFF:
		take_off_time += delta
		if take_off_time >= take_off_duration:
			state = JUMP
			take_off_time = 0
			direction = _check_direction()
			var force = jump_force if target == null else assault_force
			velocity.x = direction * force.x
			velocity.y = force.y
			$Audio/Jump.pitch_scale = rand_range(1.1, 1.5)
			$Audio/Jump.play()
	if state == JUMP:
		state_duration -= delta
		if is_on_floor():
			if state_duration <= 0:
				state = IDLE
				state_duration = rand_range(0.1, 1.5)
				velocity.x = 0
	velocity.y += gravity * delta
	
	# Apply movment
	velocity.x = clamp(velocity.x, -max_speed.x, max_speed.x)
	velocity.y = clamp(velocity.y, -max_speed.y, max_speed.y)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
	if state == IDLE:
		sprite.play("idle")
	elif state == TAKEOFF:
		sprite.play("takeoff")
	elif state == JUMP:
		sprite.play("jump")

func _check_direction():
	if not ground_check_left.is_colliding():
		return 1
	elif not ground_check_right.is_colliding():
		return -1
	elif wall_check_left.is_colliding():
		return 1
	elif wall_check_right.is_colliding():
		return -1
	elif target != null:
		var offset = global_position.x - target.global_position.x
		return -1 if offset > 0 else 1
	elif direction == 0:
		return 1 if sprite.flip_h else -1
	else:
		return direction

func warp():
	if state == NONE:
		return
	state = NONE
	velocity = Vector2.ZERO
	animation.play("scale_down")
	yield(get_tree().create_timer(0.5), "timeout")
	global_position = spawn_point
	animation.play_backwards("scale_down")
	yield(get_tree().create_timer(0.5), "timeout")
	state = IDLE
	state_duration = 1.0

func _on_HitBox_body_entered(body):
	if body.has_method("warp"):
		if player_spawn != Vector2.ZERO:
			body.warp(true, type, player_spawn)
		else:
			body.warp(true, type)
		self.warp()

func _on_DetectArea_body_entered(body):
	if body is Player:
		target = body
		
func _on_DetectArea_body_exited(body):
	if body is Player:
		target = null

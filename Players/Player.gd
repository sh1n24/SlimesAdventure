# Created by sh1n24

extends KinematicBody2D
class_name Player

const FLOOR_NORMAL = Vector2(0, -1)
enum { PINK, BLUE }	# Type
enum { IDLE, WALK, TAKEOFF, RISE, MIDAIR, FALL, LAND, NONE }	# States

export var spawn_point : Vector2 = Vector2.ZERO	# Point of respawn
export var gravity = 750.0
export var acceleration = Vector2(1000.0, -1000.0)
export var max_speed = Vector2(90, 1000.0)
export var jump_force = Vector2(90, -310.0)
export var jump_abort_acc = 220.0
export var take_off_duration = 0.15	# Duration of take off animation
export var friction = 0.55
export var max_jump_times = 2
export var type : int = PINK

var state = IDLE
var velocity : Vector2
var take_off_time = 0.0
var is_on_ground = false
var direction = 0
var jump_times = max_jump_times	# Rest available jump times
var jump_pressed = false
var jump_pressing = false

var sprite : AnimatedSprite
onready var ground_check = $GroundCheck
onready var animation = $AnimationPlayer

func _ready():
#	Engine.time_scale = 0.2	# Slow motion testing
	if spawn_point == Vector2.ZERO:
		spawn_point = Vector2(global_position)
	change_type(type)
	
func _process(delta):
	direction = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	if Input.is_action_just_pressed("jump"):
		jump_pressed = true
	jump_pressing = Input.is_action_pressed("jump")

func _physics_process(delta):
	if state == NONE:
		return
	
	is_on_ground = _ground_check()
	
	# States changing
	if state == IDLE:
		if direction != 0:
			state = WALK
	
	if state == WALK:
		if direction == 0:
			state = IDLE
	
	if state == IDLE or state == WALK:
		if jump_pressing:
			jump_pressed = false
			state = TAKEOFF
	
	if state == RISE or state == MIDAIR or state == FALL:
		if jump_pressed:
			jump_pressed = false
			if jump_times > 0:
				state = TAKEOFF
				take_off_time += 0.01	# Take off in the air takes less time
	
	if state == TAKEOFF:
		take_off_time += delta
		if take_off_time >= take_off_duration:
			# Anim finish, do the jump
			state = RISE
			take_off_time = 0.0
			velocity.y = jump_force.y
			jump_times -= 1
			$Audio/Jump.pitch_scale = rand_range(0.5, 0.7)
			$Audio/Jump.play()
	
	if state == RISE:
		# Hold jump key to jump higher
		if not jump_pressing and velocity.y < 0:
			if max_jump_times == 2 and jump_times <= 0:
				pass
			else:
				velocity.y += jump_abort_acc * delta
	
	# Horizontal movement
	if direction != 0:
		velocity.x += direction * acceleration.x * delta
	else:
		velocity.x = approach(velocity.x, 0, abs(velocity.x * friction))
	
	# Vertical movement
	if is_on_ground:
		velocity.y += gravity * delta * 0.1 
	else:
		velocity.y += gravity * delta
	
	# Apply movment
	velocity.x = clamp(velocity.x, -max_speed.x, max_speed.x)
	velocity.y = clamp(velocity.y, -max_speed.y, max_speed.y)
	velocity = move_and_slide(velocity, FLOOR_NORMAL, true)
	
	# State changing
	if is_on_ground:
		if state == MIDAIR or state == FALL:
			state = LAND
		elif state == LAND:
			state = IDLE
			velocity.x = 0
			jump_times = max_jump_times
	elif state != TAKEOFF:	# Avoid double jump failure
		if state == IDLE or state == WALK:
			jump_times -= 1	# When fall from platform, decrease jump times by 1
		if approx(velocity.y, 0, 50):
			state = MIDAIR
		elif velocity.y > 50:
			state = FALL
	
	# Apply sprite animation
	_apply_sprite_animation()

func _ground_check():
	for ray in ground_check.get_children():
		ray.force_raycast_update()
		if ray.is_colliding():
			return true
	return false

func _apply_sprite_animation():
#	print_debug("State: ", state)
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
	match state:
		IDLE:
			sprite.play("idle")
		WALK:
			sprite.play("walk")
		TAKEOFF:
			sprite.play("takeoff")
		RISE:
			sprite.play("rise")
		MIDAIR:
			sprite.play("midair")
		FALL:
			sprite.play("fall")
		LAND:
			sprite.play("land")

func warp(is_reset : bool, new_type : int = -1, spawn_point = null):
	if state == NONE:
		return
	state = NONE
	if new_type != -1:
		sprite.play("cry")
	animation.play("scale_down")
	$Audio/Blip.pitch_scale = rand_range(0.8, 1.2)
	$Audio/Blip.play()
	if is_reset:
		yield(get_tree().create_timer(0.5), "timeout")
		reset(new_type, spawn_point)

func reset(new_type : int = -1, spawn_point = null):
	if spawn_point != null:
		global_position = spawn_point
	else:
		global_position = self.spawn_point
	if new_type != -1:
		if type != new_type:
			change_type(new_type)
		sprite.play("cry")
	# Reset the jump variables
	jump_pressed = false
	jump_pressing = false
	jump_times = max_jump_times
	animation.play_backwards("scale_down")
	yield(get_tree().create_timer(0.5), "timeout")
	# Reset state
	if _ground_check():
		state = IDLE
	else:
		state = FALL
		jump_times -= 1

func change_type(new_type):
	type = new_type
	if new_type == PINK:
		sprite = $PinkSprite
		$BlueSprite.hide()
		max_jump_times = 1
	elif new_type == BLUE:
		sprite = $BlueSprite
		$PinkSprite.hide()
		max_jump_times = 2
	sprite.show()

static func approx(a, b, epsilon = 0.01):
	return abs(a - b) < epsilon

static func approach(start, end, amount):
	if (start < end):
		return min(start + amount, end)
	else:
		return max(start - amount, end)

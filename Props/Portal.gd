# Created by sh1n24

extends Node2D

enum {PINK, BLUE}

export var type : int = PINK
export var open_on_ready = false

onready var sprite = $AnimatedSprite
onready var area = $Area2D
onready var animation = $AnimationPlayer

var is_on = false

func _ready():
	if open_on_ready:
		_on_open_portal()
		return
	sprite.play("invisible")
	_toggle_area(false)

func _toggle_area(is_on : bool):
	area.set_collision_layer_bit(3, is_on)
	area.set_collision_mask_bit(1, is_on)

func _on_open_portal():
	if is_on:
		return
	if type == PINK:
		sprite.play("show_pink")
	else:
		sprite.play("show_blue")
	_toggle_area(true)

func _on_Area2D_body_entered(body):
	if body is Player:
		if body.type == type:
			body.warp(false)
			yield(get_tree().create_timer(1.0), "timeout")
			Global.next_level()
		else:
			animation.play("shake")

# Created by sh1n24

extends Node2D

signal diamond_collected

var spwan_point : Vector2
var collected = false

onready var area = $Area2D
onready var animation = $AnimationPlayer

func _ready():
	spwan_point = global_position

func _on_Area2D_body_entered(body):
	if collected:
		return
	collected = true
	area.set_collision_layer_bit(3, false)
	area.set_collision_mask_bit(2, false)
	emit_signal("diamond_collected")
	animation.play("collected")
	$Audio/Pickup.pitch_scale = rand_range(0.8, 1.2)
	$Audio/Pickup.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()

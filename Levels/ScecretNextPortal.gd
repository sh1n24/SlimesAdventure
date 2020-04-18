# Created by sh1n24

extends Area2D

onready var animation = $"../AnimationPlayer"

func _ready():
	yield(get_tree().create_timer(2.0), "timeout")
	animation.play("greetings")

func _on_Portal_body_entered(body):
	Global.secret_next()


# Created by sh1n24

extends Area2D

func _on_SecretPortal_body_entered(body):
	Global.secret_level()

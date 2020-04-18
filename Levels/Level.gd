# Created by sh1n24

extends Node2D

signal open_portal

export var diamond_count : int

func _on_diamond_collected():
	diamond_count -= 1
	if diamond_count == 0:
		emit_signal("open_portal")

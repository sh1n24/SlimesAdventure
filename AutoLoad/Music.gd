# Created by sh1n24

extends Node2D

onready var audio = $AudioStreamPlayer

func _ready():
	if not audio.playing:
		yield(get_tree().create_timer(1.0), "timeout")
		audio.play()

func _process(delta):
	if Input.is_action_just_pressed("ui_mute_music"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("BGM"), !AudioServer.is_bus_mute(AudioServer.get_bus_index("BGM")))
	if Input.is_action_just_pressed("ui_mute_sfx"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), !AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))

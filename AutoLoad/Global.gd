# Created by sh1n24

extends Node

var levels = [
#	"res://Levels/TestScene.tscn",
	"res://Levels/Start.tscn",
	"res://Levels/Level0.tscn",
	"res://Levels/Level1.tscn",
	"res://Levels/Level2.tscn",
	"res://Levels/Level3.tscn",
	"res://Levels/Level4.tscn",
	"res://Levels/Level5.tscn",
	"res://Levels/Level6.tscn",
	"res://Levels/Level7.tscn",
	"res://Levels/Level8.tscn",
	"res://Levels/Level9.tscn",
	"res://Levels/Level10.tscn",
	"res://Levels/Level14.tscn",
	"res://Levels/Level11.tscn",
	"res://Levels/Level12.tscn",
	"res://Levels/Level13.tscn",
	"res://Levels/Fin.tscn",
]

var current = 0
var current_path = levels[current]
var in_secret = false

func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		reload()

func reload():
	if in_secret:
		return
	get_tree().change_scene(current_path)

func next_level():
	current += 1
	if current > levels.size() - 1:
		current = 0
	current_path = levels[current]
	get_tree().change_scene(current_path)
	
func secret_level():
	var in_secret = true
	current_path = "res://Levels/SecretLevel.tscn"
	get_tree().change_scene(current_path)

func secret_next():
	var in_secret = false
	current_path = "res://Levels/SecretNext.tscn"
	get_tree().change_scene(current_path)
	

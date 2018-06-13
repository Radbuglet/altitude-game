extends Node

export (String) var lvl_name
export (String, FILE, "*.tscn") var scene

func _ready():
	pass

func get_scene_path():
	return scene

func get_name():
	return lvl_name
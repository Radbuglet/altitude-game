extends Button

export (PackedScene) var main_scene

func _pressed():
	get_tree().paused = false
	get_tree().change_scene_to(main_scene)
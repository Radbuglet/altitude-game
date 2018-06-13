extends Button

var manager

func _ready():
	manager = get_node("/root/progress_manager").get_data_manager()

func _pressed():
	var profile = manager.get_active_profile()
	profile.get_level_by_index(get_parent().get_node("Levels").get_selected_id()).load_level()
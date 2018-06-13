extends OptionButton

func _ready():
	var manager = get_node("/root/progress_manager").get_data_manager()
	var profile = manager.get_active_profile()
	
	var earliest_uncomplete_level = -1
	for level_id in profile.get_levels_list():
		var level = profile.get_level_by_id(level_id)
		self.add_item(level.get_level_name() + (" [COMPLETED]" if level.is_completed() else ""), level.get_index())
		
		if earliest_uncomplete_level == -1 and not level.is_completed():
			earliest_uncomplete_level = level.get_index()
	
	if earliest_uncomplete_level != -1:
		select(earliest_uncomplete_level)
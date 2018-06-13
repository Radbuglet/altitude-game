extends Node

# Class deffinitions
class LevelCompletionState:
	var level_id
	var level_index
	var is_completed_state
	var service_node
	
	func _init(service_node, index, level_id):
		self.service_node = service_node
		self.level_id = level_id
		self.level_index = index
		self.is_completed_state = false
	
	func get_level_id():
		return level_id
	
	func is_completed():
		return is_completed_state
	
	func complete_level():
		is_completed_state = true
	
	func load_level():
		service_node.get_tree().change_scene(get_level_data_node().get_scene_path())
	
	func get_level_name():
		return get_level_data_node().get_name()
	
	func get_level_data_node():
		return service_node.get_node("levels").get_node(get_level_id())
	
	func get_index():
		return level_index
	
	func loadJSON(json_data):
		is_completed_state = json_data.is_completed
	
	func toJSON():
		return {
			"level_id": get_level_id(),
			"is_completed": is_completed()
		}

class Profile:
	var profile_name
	var profile_color
	var service_node
	var levels
	
	func _init(service_node, profile_name, profile_color):
		self.service_node = service_node
		self.profile_name = profile_name
		self.profile_color = profile_color
		self.levels = {}
		
		var index = 0
		for level_id in service_node.get_all_levels():
			self.levels[level_id] = LevelCompletionState.new(service_node, index, level_id)
			index += 1
	
	func set_profile_name(new_name):
		profile_name = new_name
	
	func set_profile_color(new_color):
		profile_color = new_color
	
	func get_name():
		return profile_name
	
	func get_color():
		return profile_color
	
	func get_levels_list():
		return levels
	
	func get_level_by_id(level_id):
		return levels[level_id]
	
	func get_level_by_index(index):
		return levels[service_node.get_all_levels()[index]]
	
	func toJSON():
		var levels_json = []
		
		for key in levels:
			var lvl = levels[key]
			levels_json.append(lvl.toJSON())
		
		return {
			"name": profile_name,
			"color": profile_color,
			"levels": levels_json
		}

class DataManager:
	var save_path = "user://profile_data_e1.json"
	
	var profiles = []
	var active_profile_index = 0
	var service_node
	
	func _init(service_node):
		self.service_node = service_node
		
		var f = File.new()
		if f.file_exists(save_path):
			f.open(save_path, File.READ)
			
			var json_contents = {}
			
			json_contents = JSON.parse(f.get_as_text()).result
			
			if json_contents != null and json_contents.has('profiles'):
				for profile_json in json_contents.profiles:
					var profile = Profile.new(service_node, profile_json.name, profile_json.color)
					
					for level_comp_json in profile_json.levels:
						profile.levels[level_comp_json.level_id].loadJSON(level_comp_json)
					profiles.append(profile)
				f.close()
				return
			else:
				f.close()
		new_profile("Default Profile")
		save_to_file()
	
	func save_to_file():
		var json_data = {
			"profiles": []
		}
		
		for profile in profiles:
			json_data.profiles.append(profile.toJSON())
		
		var f = File.new()
		f.open(save_path, File.WRITE)
		f.store_string(JSON.print(json_data, "	"))
		f.close()
	
	# Profile management
	func new_profile(name):
		profiles.append(Profile.new(service_node, name, 100))
		active_profile_index = len(profiles) - 1
	
	func remove_active_profile():
		profiles.remove(active_profile_index)
		
		if profiles.length < 1:
			new_profile("Default profile", 100)
		else:
			active_profile_index = profiles.length - 1
	
	func select_profile(index):
		active_profile_index = index
	
	func get_active_profile():
		return profiles[active_profile_index]

# Vars
var data_manager

# Methods
func _ready():
	print("ProgressManager singleton loaded!")
	
	data_manager = DataManager.new(self)

func get_all_levels():
	var level_ids = []
	
	for level_node in $levels.get_children():
		level_ids.append(level_node.name)
	
	return level_ids

func get_data_manager():
	return data_manager
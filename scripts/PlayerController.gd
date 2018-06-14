extends KinematicBody

signal enable_state_changed

# State
var enabled = false
var win_ticks_left = -1

export (String) var current_level_id
export (PackedScene) var win_scene
var single_time_ns_fired = false

# Needed nodes
var camera
var effect_declarations_node

# Movement
var last_forward_press = 0
var jump_power = 7.5
var xz_move_vector = Vector2()
var current_speed = 4
var desired_vec_weight = 0.25
var velocity = Vector3()
var is_sprinting = false
var camera_fov_lerp = 0

# Respawning & Dying
var spawn_point = self.transform.origin
var dying_anim_ticks = -1
var dying_fov_anim_amount = 0

# Elevation (With some dying)
export var min_y = -10
export var max_y = 20

export (Array, String) var climates
var parsed_climates = []

var acclimated_elevation
var current_climate_object
var current_csection_index

func parse_error(index, reason):
	print("Failed to parse level climates! Index: " + str(index) + " Reason: " + str(reason))
		
func _ready():
	print("Init Controller")
	
	camera = $Camera
	
	acclimated_elevation = get_elevation()
	var valid_climate_type_names = []
	
	effect_declarations_node = $EffectDeclarations
	
	for c in effect_declarations_node.get_children():
		print("Found mode " + c.name)
		valid_climate_type_names.append(c.name)
	
	# Parse climates
	var parse_elev = min_y
	for i in range(0, len(climates)):
		var climate_layer_str = climates[i]
		var split_str = climate_layer_str.split("=")
		
		if len(split_str) != 2:
			parse_error(i, "Invalid format!")
			break
		
		if !(split_str[1] in valid_climate_type_names):
			parse_error(i, split_str[1] + " isn't a valid climate type!")
			break
		
		parsed_climates.append({
			"climate_id": split_str[1],
			"min_elevation": parse_elev,
			"max_elevation": parse_elev + float(split_str[0])
		})
		
		parse_elev += float(split_str[0])
	
	# Create GUI components
	$AltitudeGUI.init()

	# Initialize to current_climate
	var current_section = get_climate()
	if current_section != null:
		set_climate(current_section.id, current_section.section_index)
	
	enable()

func enable():
	Input.set_mouse_mode(2)
	camera.set_has_control(true)
	enabled = true
	
	emit_signal("enable_state_changed", true)

func disable():
	Input.set_mouse_mode(0)
	camera.set_has_control(false)
	enabled = false
	
	emit_signal("enable_state_changed", false)

func win():
	if not is_winning():
		win_ticks_left = 1

func is_winning():
	return win_ticks_left > -1

func _process(delta):
	if enabled:
		var desired_xz_move_vector = Vector2(0, 0) # Y = forwards / backwards & X = Strafe
			
		if Input.is_action_pressed("control_forward"):
			desired_xz_move_vector.y += -1
		else:
			is_sprinting = false
		
		if Input.is_action_just_pressed("control_forward"):
			if last_forward_press > 0:
				is_sprinting = true
			else:
				last_forward_press = 0.5
		
		if Input.is_action_pressed("control_backward"):
			desired_xz_move_vector.y += 1
		
		if Input.is_action_pressed("control_strafe_left"):
			desired_xz_move_vector.x += -1
		
		if Input.is_action_pressed("control_strafe_right"):
			desired_xz_move_vector.x += 1
		
		# Weighted averages
		var actual_speed = current_speed
		if is_sprinting:
			actual_speed += 2
		desired_xz_move_vector = desired_xz_move_vector.normalized() * actual_speed
		xz_move_vector.x = (xz_move_vector.x + desired_xz_move_vector.x * desired_vec_weight) / (1 + desired_vec_weight)
		xz_move_vector.y = (xz_move_vector.y + desired_xz_move_vector.y * desired_vec_weight) / (1 + desired_vec_weight)
		
		# Setting velocity
		var cbasis = Basis(Vector3(0, 1, 0), deg2rad(camera.get_x_rot()))
		var vel_vec = (cbasis.z * xz_move_vector.y) + (cbasis.x * xz_move_vector.x)
		velocity.x = vel_vec.x
		velocity.z = vel_vec.z
		
		# Jumping & Gravity
		if not is_on_floor():
			velocity.y -= 0.13 * 2.5 * get_phys_speed()
		else:
			if velocity.y < 0:
				velocity.y = 0
		
		var air_jump_hack_enabled = get_node("PauseMenu/PauseMenuRoot/MarginContainer/HBoxContainer/VBoxContainer2/AirJumpChb").is_pressed()
		if (is_on_floor() and Input.is_action_pressed("control_jump")) or (Input.is_action_just_pressed("control_jump") and air_jump_hack_enabled):
			velocity.y = jump_power
		
		if last_forward_press > 0:
			last_forward_press -= delta
		
		if is_on_ceiling():
			velocity.y = 0
		
		# Applying Velocity
		move_and_slide(velocity * get_phys_speed(), Vector3(0, 1, 0))
		
		if is_winning():
			win_ticks_left -= delta
			win_ticks_left = max(win_ticks_left, 0)
			
			if win_ticks_left <= 0:
				if not single_time_ns_fired:
					print("Go to next scene!")
					single_time_ns_fired = true
					var manager = get_node("/root/progress_manager").get_data_manager()
					var active_profile = manager.get_active_profile()
					var current_level = active_profile.get_level_by_id(current_level_id)
					current_level.complete_level()
					
					var next_level_index = current_level.get_index() + 1
					
					if next_level_index >= len(active_profile.get_levels_list()):
						get_tree().change_scene_to(win_scene)
						print("THIS WAS THE LAST LEVEL!")
					else:
						active_profile.get_level_by_index(next_level_index).load_level()
					
					manager.save_to_file()
			else:
				print("Animate " + str(win_ticks_left))
		
		if dying_anim_ticks == -1:
			# Check if in void
			if transform.origin.y < min_y:
				died()
		else:
			dying_fov_anim_amount += 5
			dying_fov_anim_amount = min(dying_fov_anim_amount, 160)
			dying_anim_ticks += 1
			
			if dying_anim_ticks > 10:
				dying_anim_ticks = -1
				self.transform.origin = spawn_point
				self.acclimated_elevation = get_elevation()
		
		if dying_fov_anim_amount > 0 && dying_anim_ticks == -1:
			dying_fov_anim_amount -= 3
		
		dying_fov_anim_amount = max(0, dying_fov_anim_amount)
		
		camera.fov = 80 + camera_fov_lerp + dying_fov_anim_amount
		
		camera_fov_lerp = (camera_fov_lerp + 
			(
				(xz_move_vector.length() * (3 if is_sprinting else 1)) + (current_speed * 3)
			) * 0.25
		) / 1.25
		
		var abs_change_to_ace = min(0.0325, abs(get_elevation() - acclimated_elevation))
		acclimated_elevation += abs_change_to_ace * sign(get_elevation() - acclimated_elevation)
		
		# Change climate
		if get_climate() != null and get_climate().section_index != current_csection_index:
			var current_section = get_climate()
			set_climate(current_section.id, current_section.section_index)
		else:
			if current_climate_object != null:
				current_climate_object.onUpdate(self, delta)

func get_phys_speed():
	return (0.2 if (is_winning() or dying_anim_ticks > -1) else 1)

func set_spawnpoint():
	spawn_point = self.transform.origin

func died():
	dying_anim_ticks = 0

func get_elevation():
	return transform.origin.y

func set_climate(climate_id, climate_index):
	if current_climate_object != null:
		current_climate_object.onDisabled(self)
		current_csection_index = climate_index
	
	current_climate_object = effect_declarations_node.find_node(climate_id)
	current_climate_object.onEnabled(self)

func get_climate():
	var elev = acclimated_elevation
	var x = 0
	for climate in parsed_climates:
		if elev >= climate.min_elevation and elev < climate.max_elevation:
			return { "id": climate.climate_id, "section_index": x }
		x += 1
	return null

func get_current_climate():
	return current_climate_object.name
	
func get_acclimated_elevation():
	return acclimated_elevation
extends CanvasLayer

var player
var actual_elevation_display
var acclimated_elevation_display
var min_elevation_disp

var visible = true
var climate_gui_components = []
var has_been_initialized = false

export (PackedScene) var ClimatePartGUIScene 

func init():
	print("Init GUI")
	player = self.get_parent()
	actual_elevation_display = $ActualElevation
	acclimated_elevation_display = $AcclimatedElevation
	min_elevation_disp = $MinElevation
	
	var x = 0
	for pclimate in player.parsed_climates:
		var gui_e = ClimatePartGUIScene.instance()
		gui_e.color = player.effect_declarations_node.get_node(pclimate.climate_id).getColor()
		add_child(gui_e)
		climate_gui_components.append({
			"section_index": x,
			"gui_elem": gui_e,
			"climate_world_data": pclimate
		})
		
		x += 1
	
	has_been_initialized = true

func _process(delta):
	if visible and has_been_initialized:
		var player_elevation = player.get_elevation()
		var player_acclimated_elevation = player.get_acclimated_elevation()
		var min_elevation = player.min_y
		var max_elevation = player.max_y
		
		actual_elevation_display.set_displayed_elevation(player_elevation, max_elevation, min_elevation, true)
		acclimated_elevation_display.set_displayed_elevation(player_acclimated_elevation, max_elevation, min_elevation, true)
		
		min_elevation_disp.set_displayed_elevation(0, max_elevation, min_elevation, true)
		
		for climate_section in climate_gui_components:
			if climate_section.section_index == player.current_csection_index:
				climate_section.gui_elem.rect_size.x = 10
			else:
				climate_section.gui_elem.rect_size.x = 5
				
			climate_section.gui_elem.set_displayed_elevation(climate_section.climate_world_data.max_elevation, max_elevation, min_elevation, false)
			climate_section.gui_elem.climate_section_set_size(climate_section.climate_world_data.max_elevation - climate_section.climate_world_data.min_elevation, max_elevation, min_elevation)
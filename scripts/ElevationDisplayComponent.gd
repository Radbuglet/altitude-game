extends Control

func set_displayed_elevation(player_elevation, emax, emin, move_from_center):
	var percent = (player_elevation - emin) / (emax - emin)
	var viewport_height = self.get_viewport_rect().size.y - 100
	
	var real_y_pos = viewport_height - (viewport_height * percent)
	
	if move_from_center:
		real_y_pos -= self.get_rect().size.y * 0.05
	
	self.rect_position.y = real_y_pos

func climate_section_set_size(climate_size, emax, emin):
	var percent = (climate_size) / (emax - emin)
	var viewport_height = self.get_viewport_rect().size.y - 100
	
	var real_size = viewport_height * percent
	
	self.rect_size.y = real_size
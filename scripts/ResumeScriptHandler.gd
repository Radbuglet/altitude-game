extends Button

func _pressed():
	get_parent().get_parent().get_parent().get_parent().change_pause_state()
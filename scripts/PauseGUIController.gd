extends Control

var player

func _ready():
	self.visible = false
	
	player = self.get_parent().get_parent()

func _process(dt):
	if Input.is_action_just_pressed("control_pause"):
		change_pause_state()

func change_pause_state():
	get_tree().paused = !get_tree().paused
		
	if get_tree().paused:
		player.disable()
	else:
		player.enable()
	self.visible = get_tree().paused

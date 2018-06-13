extends Area

var is_player_touching = false
var player = null

func _on_Area_body_entered(body):
	if body is KinematicBody: # @TODO Check if is a player
		is_player_touching = true
		player = body

func _process(dt):
	if is_player_touching:
		player.acclimated_elevation = player.get_elevation()

func _on_AcclimationTrigger_body_exited(body):
	if body is KinematicBody: # @TODO Check if is a player
		is_player_touching = false

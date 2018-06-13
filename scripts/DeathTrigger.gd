extends Area


func _on_Area_body_entered(body):
	if body is KinematicBody: # @TODO Check if is a player
		body.died()
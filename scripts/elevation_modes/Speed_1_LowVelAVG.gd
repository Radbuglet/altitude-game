extends Node

func onEnabled(player):
	pass

func onUpdate(player, dt):
	player.desired_vec_weight = 0.01
	player.current_speed = 8

func onDisabled(player):
	player.desired_vec_weight = 0.25
	player.current_speed = 4

func getColor():
	return Color(0.1, 0.2, 0.1)
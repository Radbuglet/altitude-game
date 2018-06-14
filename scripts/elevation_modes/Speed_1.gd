extends Node

func onEnabled(player):
	pass

func onUpdate(player, dt):
	player.current_speed = 8

func onDisabled(player):
	player.current_speed = 4

func getColor():
	return Color(0.2, 0.7, 0.2)
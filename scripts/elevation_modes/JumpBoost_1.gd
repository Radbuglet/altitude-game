extends Node

func onEnabled(player):
	pass

func onUpdate(player, dt):
	player.jump_power = 15

func onDisabled(player):
	player.jump_power = 7.5

func getColor():
	return Color(0.2, 0.7, 0.7)
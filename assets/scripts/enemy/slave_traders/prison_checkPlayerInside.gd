extends Area

onready var enemy_manager = get_node("/root/Main/enemies")
var player_inside = false


func _on_checkPlayerInside_body_entered(body):
	if body.name == "Player":
		player_inside = true
		if G.player.stealth.stage != 0:
			enemy_manager.MakeEveryoneCalm()
			var closerTrader = enemy_manager._getCloserTrader()
			if closerTrader:
				closerTrader.closePrison()


func _on_checkPlayerInside_body_exited(body):
	if body.name == "Player":
		player_inside = false
		enemy_manager.MakeEveryoneAngry()

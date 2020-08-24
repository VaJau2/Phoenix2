extends "MenuBase.gd"

export var path: String

func _on_again_pressed():
	$audi.play()
	updating_down_label = false
	G.game_over = false
	G.setPause(self, false)
	G.goto_scene(path, true)


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.2),"timeout")
	G.game_over = false
	G.goto_scene("MainMenu")

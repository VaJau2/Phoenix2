extends "MenuBase.gd"

func _changeCameraRay(): #правим рейкаст от камеры, если игрок растягивал окошко
	var camera = get_node("/root/Main/Player/Rotation_Helper/Camera")
	if camera:
		camera._pos = OS.get_window_size() / 2


func _set_pause(pause):
	G.setPause(self, pause)
	visible = pause
	updating_down_label = pause
	if pause:
		_update_down_label()
	else:
		$SettingsMenu.visible = false
		$SettingsMenu.saveSettingsToFile()
		_changeCameraRay()


func _input(event):
	if !G.game_over && Input.is_action_just_pressed("ui_cancel"):
		_set_pause(!G.paused)


func _on_continue_pressed():
	$audi.play()
	_set_pause(false)


func _on_settings_pressed():
	$audi.play()
	$SettingsMenu.visible = true
	$SettingsMenu._update_down_label()


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.2),"timeout")
	G.goto_scene("MainMenu")

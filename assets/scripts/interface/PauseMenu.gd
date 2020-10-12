extends "MenuBase.gd"

var menu_text = {
	0:["/Phoenix2/Меню_паузы","/Phoenix2/Pause_menu"],
	1:["[Пауза]","[Pause]"],
	2:["               [Продолжить]","               [Continue]"],
	3:["               [Настройки]","               [Settings]"],
	4:["               [В главное меню]","               [To main menu]"]
}

func _getMenuText(textI):
	if G.english:
		return menu_text[textI][1]
	else:
		return menu_text[textI][0]


func _change_interface_language():
	$page_label.text = _getMenuText(0)
	$Label.text = _getMenuText(1)
	$continue.text = _getMenuText(2)
	$settings.text = _getMenuText(3)
	$exit.text = _getMenuText(4)


func _set_pause(pause):
	var dialogue = get_node("/root/Main/canvas/dialogue")
	if !dialogue || !dialogue.visible:
		G.setPause(self, pause)
	else:
		G.music_paused = !visible
		pause = !visible
	
	visible = pause
	updating_down_label = pause
	if pause:
		_change_interface_language()
		_update_down_label()
	else:
		$SettingsMenu.visible = false
		$SettingsMenu.saveSettingsToFile()


func _input(event):
	if !G.game_over && Input.is_action_just_pressed("ui_cancel"):
		_set_pause(!G.paused)


func _on_continue_pressed():
	$audi.play()
	_set_pause(false)


func _on_settings_pressed():
	$audi.play()
	$SettingsMenu._change_interface_language()
	$SettingsMenu.visible = true
	$SettingsMenu._update_down_label()


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.2),"timeout")
	G.goto_scene("MainMenu")

extends "MenuBase.gd"

export var header_text: Array

var mouse_slider
var distance_slider
var shadows_button
var reflections_button

var shadows_variants = {
	0:["Минимальное", "Minimum"],
	1:["Среднее", "Average"],
	2:["Выше среднего", "Above average"],
	3:["Максимальное", "Maximum"]
}
var shadows_settings = [
	1024,
	2048,
	2560,
	4096,
]
var shadows_temp = 3


var reflections_variants = {
	0:["Отключены", "Disabled"],
	1:["Низкое", "Low"],
	2:["Среднее", "Avegare"],
	3:["Максимальное", "Maximum"]
}
var reflections_settings = [
	0,
	45,
	100,
	200,
]
var reflections_temp = 3

var fullscreen_button
var fullscreen_temp = false

var sound_slider
var music_slider

onready var controls = get_node("Controls")
var temp_edit_back = null
var temp_edit = null
var temp_action = ""
var controlActions = ["ui_up", "ui_down", "ui_left", "ui_right", \
					  "jump", "ui_shift", "use", "crouch", "dash",\
					  "getGun", "legsHit", "changeView"]

var menu_text = {
	0: ["[Настройки]","[Settings]"],
	1: ["               [Назад]","               [Back]"],
	2: ["Чувствительность мыши:","Mouse sensitivity"],
	3: ["Дальность прорисовки:", "Render distance:"],
	4: ["Качество теней:", "Shadows quality:"],
	5: ["Качество отражений:", "Reflections quality:"],
	6: ["Полноэкранный режим:", "Fullscreen"],
	7: ["Громкость звуков:", "Sound volume:"],
	8: ["Громкость музыки:", "Music volume:"],
	9: ["[Настройки управления]", "[Controls settings]"],
	10:["Выключен", "Disabled"],
	11:["Включен", "Enabled"],
	12:["               [Сбросить]","               [Default]"],
	13:["Вперед:", "Forward"],
	14:["Назад:", "Back"],
	15:["Налево:", "Left"],
	16:["Направо:", "Right"],
	17:["Прыжок/Телепортация/Полет:", "Jump/Teleport/Fly Up"],
	18:["Бег/Магический щит/Снижение:", "Run/Magical Sheild/Fly Down"],
	19:["Использовать:", "Use:"],
	20:["Присесть:", "Sit"],
	21:["Подкат:", "Dodge"],
	22:["Достать оружие: ", "Get gun"],
	23:["Ближний удар:", "Close hit"],
	24:["Сменить камеру:", "Change view"]
}


func _getMenuText(textI):
	if G.english:
		return menu_text[textI][1]
	else:
		return menu_text[textI][0]


func _change_interface_language():
	if G.english:
		$page_label.text = header_text[1]
		$Controls/page_label.text = header_text[1] + "/Controls_settings"
		
		reflections_button.text = reflections_variants[reflections_temp][1]
		shadows_button.text = shadows_variants[shadows_temp][1]
		
		if fullscreen_temp:
			fullscreen_button.text = _getMenuText(11)
		else:
			fullscreen_button.text = _getMenuText(10)
	else:
		$page_label.text = header_text[0]
		$Controls/page_label.text = header_text[0] + "/Настройки_управления"
	
	$Label.text = _getMenuText(0)
	$back.text = _getMenuText(1)
	$mouse_label.text = _getMenuText(2)
	$distance_label.text = _getMenuText(3)
	$shadows_label.text = _getMenuText(4)
	$reflections_label.text = _getMenuText(5)
	$fullscreen.text = _getMenuText(6)
	$sound_label.text = _getMenuText(7)
	$music_label.text = _getMenuText(8)
	$controls.text = _getMenuText(9)
	
	$Controls/back.text = _getMenuText(1)
	$Controls/default.text = _getMenuText(12)
	$Controls/keyForwardLabel.text = _getMenuText(13)
	$Controls/keyBackLabel.text = _getMenuText(14)
	$Controls/keyLeftLabel.text = _getMenuText(15)
	$Controls/keyRightLabel.text = _getMenuText(16)
	$Controls/keyJumpLabel.text = _getMenuText(17)
	$Controls/keyRunLabel.text = _getMenuText(18)
	$Controls/keyUseLabel.text = _getMenuText(19)
	$Controls/keyCrouchLabel.text = _getMenuText(20)
	$Controls/keyDashLabel.text = _getMenuText(21)
	$Controls/keyGetGunLabel.text = _getMenuText(22)
	$Controls/keyLegsLabel.text = _getMenuText(23)
	$Controls/keyCameraLabel.text = _getMenuText(24)


func _on_back_pressed():
	$audi.play()
	visible = false
	updating_down_label = false
	saveSettingsToFile()


func _on_mouse_slider_value_changed(value):
	G.sensivity = value
	if G.player:
		G.player.MOUSE_SENSITIVITY = value


func _on_distance_slider_value_changed(value):
	G.distance = value
	if G.player:
		G.player.rotation_helper_third.third_camera.set_zfar(value)
		G.player.rotation_helper_third.first_camera.set_zfar(value)


func changeShadows(num):
	var temp_shadow_settings = shadows_settings[num]
	get_tree().get_root().set_shadow_atlas_size(temp_shadow_settings)


func _on_shadows_button_pressed():
	$audi.play()
	if shadows_temp < shadows_variants.size() - 1:
		shadows_temp += 1
	else:
		shadows_temp = 0
	if G.english:
		shadows_button.text = shadows_variants[shadows_temp][1]
	else:
		shadows_button.text = shadows_variants[shadows_temp][0]
	changeShadows(shadows_temp)


func _on_reflections_button_pressed():
	$audi.play()
	if reflections_temp < reflections_variants.size() - 1:
		reflections_temp += 1
	else:
		reflections_temp = 0
	if G.english:
		reflections_button.text = reflections_variants[reflections_temp][1]
	else:
		reflections_button.text = reflections_variants[reflections_temp][0]
	G.reflections = reflections_settings[reflections_temp]


func _update_fullscreen_button():
	if fullscreen_temp:
		fullscreen_button.text = _getMenuText(11)
	else:
		fullscreen_button.text = _getMenuText(10)


func _on_fullscreen_button_pressed():
	$audi.play()
	fullscreen_temp = !fullscreen_temp
	_update_fullscreen_button()
	OS.window_fullscreen = fullscreen_temp


func _update_audio_bus(num, value):
	AudioServer.set_bus_volume_db(num, value)
	AudioServer.set_bus_mute(num, value == -8)


func _on_sound_slider_value_changed(value):
	_update_audio_bus(0, value)


func _on_music_slider_value_changed(value):
	_update_audio_bus(1, value)


func _on_controls_pressed():
	$audi.play()
	controls.visible = true


func _on_controls_back_pressed():
	$audi.play()
	_cancelControlEdit()
	controls.visible = false


func _writeKeyToEdit(key, edit):
	var spacing = "     "
	var key_len = key.length()
	if key_len > 1:
		var spasing_len = spacing.length()
		if key_len >= spasing_len:
			spacing = ""
		else:
			spacing = spacing.substr(0, (spasing_len - (key_len)/2) - 1)
	
	edit.text = "[" + spacing + key.capitalize() + spacing + "]" 


func _cancelControlEdit():
	if temp_action != "":
		_setEditOn(temp_edit_back, false)
		var actions = InputMap.get_action_list(temp_action)
		var key = OS.get_scancode_string(actions[0].get_scancode())
		if temp_edit:
			_writeKeyToEdit(key, temp_edit)
		temp_action = ""
		temp_edit = null


func _setEditOn(editBack, on):
	var editButton = editBack.get_node("edit")
	if on:
		editBack.color.a = 1
		editButton.modulate = Color.black
		temp_edit_back = editBack
	else:
		editBack.color.a = 0
		editButton.modulate = Color.white
		temp_edit_back = null


func _getControlEdit(action):
	match action:
		"ui_up":
			return $Controls/forwardBack/edit
		"ui_down":
			return $Controls/backBack/edit
		"ui_left":
			return $Controls/leftBack/edit
		"ui_right":
			return $Controls/rightBack/edit
		"jump":
			return $Controls/jumpBack/edit
		"ui_shift":
			return $Controls/runBack/edit
		"use":
			return $Controls/useBack/edit
		"crouch":
			return $Controls/crouchBack/edit
		"dash":
			return $Controls/dashBack/edit
		"getGun":
			return $Controls/getGunBack/edit
		"legsHit":
			return $Controls/legsBack/edit
		"changeView":
			return $Controls/cameraBack/edit
	print("what is " + action + "?")


func _on_controls_mouse_entered(editName, text, eng_text = ""):
	if temp_edit == null:
		._on_mouse_entered(text, eng_text)
		var editBack = get_node("Controls/"+ editName)
		_setEditOn(editBack, true)


func _on_controls_mouse_exited():
	if temp_edit == null && temp_edit_back:
		._on_mouse_exited()
		_setEditOn(temp_edit_back, false)


func _on_controls_gui_input(event, action):
	if temp_edit == null:
		if event is InputEventMouseButton && event.pressed:
			_cancelControlEdit() #стираем предыдущий
			temp_edit = temp_edit_back.get_node("edit")
			temp_edit.text = "[            ]"
			temp_action = action


func _on_default_pressed():
	InputMap.load_from_globals()
	for action in controlActions:
		var actions = InputMap.get_action_list(action)
		var key = OS.get_scancode_string(actions[0].get_scancode())
		var edit = _getControlEdit(action)
		_writeKeyToEdit(key, edit)


func _input(event):
	if temp_edit != null:
		if event is InputEventKey && event.pressed:
			if event.get_scancode() == KEY_ESCAPE:
				_cancelControlEdit()
			else:
				InputMap.action_erase_events(temp_action)
				InputMap.action_add_event(temp_action, event)
				var key = OS.get_scancode_string(event.get_scancode())
				_writeKeyToEdit(key, temp_edit)
				temp_action = ""
				_setEditOn(temp_edit_back, false)
				temp_edit = null


#--------Вызывается в global.gd и [скрипт загрузки]---------------------------------------

func loadInterface():
	mouse_slider = get_node("mouse_slider")
	distance_slider = get_node("distance_slider")
	shadows_button = get_node("shadows_button")
	reflections_button = get_node("reflections_button")
	fullscreen_button = get_node("fullscreen_button")
	sound_slider = get_node("sound_slider")
	music_slider = get_node("music_slider")


#это вызывается, когда загружается уровень, и вытаскивается его менюшка паузы
func loadSettingsFromGame():
	mouse_slider.value = G.sensivity
	for action in controlActions:
		var actions = InputMap.get_action_list(action)
		var key = OS.get_scancode_string(actions[0].get_scancode())
		var edit = _getControlEdit(action)
		_writeKeyToEdit(key, edit)
	
	distance_slider.value = G.distance
	var shadows = get_tree().get_root().get_shadow_atlas_size()
	
	var lang = 0
	if G.english:
		lang = 1
		
	match shadows:
		512:
			shadows_button.text = shadows_variants[0][lang]
		1024:
			shadows_button.text = shadows_variants[1][lang]
			shadows_temp = 1
		2048:
			shadows_button.text = shadows_variants[2][lang]
			shadows_temp = 2
		4096:
			shadows_button.text = shadows_variants[3][lang]
			shadows_temp = 3
	
	reflections_temp = reflections_settings.find(G.reflections)
	if G.english:
		reflections_button.text = reflections_variants[reflections_temp][1]
	else:
		reflections_button.text = reflections_variants[reflections_temp][0]
	
	sound_slider.value = AudioServer.get_bus_volume_db(0)
	music_slider.value = AudioServer.get_bus_volume_db(1)
	fullscreen_temp = OS.is_window_fullscreen()
	_update_fullscreen_button()


func loadSettingsFromFile():
	var config = ConfigFile.new()
	var err = config.load("res://settings.cfg")
	if err == OK:
		var mouse_sensivity = config.get_value("controls", "mouse_sensivity")
		G.sensivity = mouse_sensivity
		mouse_slider.value = mouse_sensivity
		
		for action in controlActions:
			var key = config.get_value("controls", action)
			var key_code = OS.find_scancode_from_string(key)
			var new_event = InputEventKey.new()
			new_event.set_scancode(key_code)
			
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, new_event)
			
			var edit = _getControlEdit(action)
			_writeKeyToEdit(key, edit)
		
		var distance = config.get_value("screen", "distance")
		G.distance = distance
		distance_slider.value = distance
		
		shadows_temp = config.get_value("screen", "shadows_quality")
		if G.english:
			shadows_button.text = shadows_variants[shadows_temp][1]
		else:
			shadows_button.text = shadows_variants[shadows_temp][0]
		changeShadows(shadows_temp)
		
		reflections_temp = config.get_value("screen", "reflections_quality")
		if G.english:
			reflections_button.text = reflections_variants[reflections_temp][1]
		else:
			reflections_button.text = reflections_variants[reflections_temp][0]
		G.reflections = reflections_settings[reflections_temp]
		
		var sound_volume = config.get_value("audio","sound_volume")
		_update_audio_bus(0, sound_volume)
		sound_slider.value = sound_volume
		
		var music_volume = config.get_value("audio","music_volume")
		_update_audio_bus(1, music_volume)
		music_slider.value = music_volume
		
		fullscreen_temp = config.get_value("screen", "fullscreen")
		_update_fullscreen_button()
		OS.set_window_fullscreen(fullscreen_temp)
		
		var screen_size = Vector2()
		screen_size.x = config.get_value("screen", "width")
		screen_size.y = config.get_value("screen", "heigh")
		
		OS.set_window_size(screen_size)


func saveSettingsToFile():
	_update_audio_bus(0, sound_slider.value)
	_update_audio_bus(1, music_slider.value)
	
	
	var config = ConfigFile.new()
	config.set_value("controls", "mouse_sensivity", mouse_slider.value)
	for action in controlActions:
		var actions = InputMap.get_action_list(action)
		var key = OS.get_scancode_string(actions[0].get_scancode())
		config.set_value("controls", action, key)
	config.set_value("screen", "distance", distance_slider.value)
	config.set_value("screen", "shadows_quality", shadows_temp)
	config.set_value("screen", "reflections_quality", reflections_temp)
	config.set_value("audio", "sound_volume", sound_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("screen", "fullscreen", fullscreen_temp)
	var screen_size = OS.get_window_size()
	config.set_value("screen", "width", screen_size.x)
	config.set_value("screen", "heigh", screen_size.y)
	config.save("res://settings.cfg")

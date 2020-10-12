extends Node

var english = false

var loader
var wait_frames
var current_scene
var time_max = 100 # msec
var main_menu

var player
var race = 0 
#0 - земнопонь
#1 - единорог
#2 - пегас
var paused = false
var music_paused = true
var game_over = false

var settings
var distance = 600 #настройки, которые сохраняются в settingsMenu
var sensivity = 0.1 #и потом берутся в player
var reflections = 200
var filter = false

var load_game = false

var scores = 0
var saved_equipment = []
var saved_coat = false
var load_equipment = false

func decreaseScores(num):
	scores -= num
	if scores < 0:
		scores = 0


func setValueZero(value, step, new_value=0, delta = 0.1):
	if(value > step + new_value):
		value -= step * delta * 20
	elif(value < -step + new_value):
		value += step * delta * 20
	else:
		value = new_value
	return value


func save_stats(stats):
	var save_file = File.new()
	save_file.open_compressed("res://stats.sav", File.WRITE, File.COMPRESSION_FASTLZ)
	var data = to_json(stats)
	save_file.store_line(data)
	save_file.close()


func load_stats():
	var load_file = File.new()
	if load_file.file_exists("res://stats.sav"):
		load_file.open_compressed("res://stats.sav", File.READ, File.COMPRESSION_FASTLZ)
		var data = load_file.get_line()
		var stats = parse_json(data)
		load_file.close()
		return stats
	
	load_file.close()
	return null

#clear - очистка файла сохранений в начале новой игры
#new_level_passed - текущий пройденный уровень, который сохраняется даже при очистке
# 0 - обучение
# 1 - база зебр
# 2 - лаборатория
func save_level(level_name, savind_stats, new_level_passed = 0, clear = false):
	var saved_stats = load_stats() #грузим предыдущие рекорды
	if saved_stats == null || clear: #если сохранений не было, создаем новые
		var levelsPassed = 0 if (saved_stats == null) else saved_stats.levelsPassed
		
		var new_stats = {
			"race": G.race,
			"levelsPassed": levelsPassed,
			"levels": {
				level_name: savind_stats,
			},
		}
		save_stats(new_stats)
	
	elif !(level_name in saved_stats.levels) || ("score" in saved_stats.levels[level_name] 
		&& !(saved_stats.levels[level_name].score < scores)): #если предыдущий рекорд побит, перезаписываем
		
		if new_level_passed > saved_stats.levelsPassed: #записываем, что прошли этот уровень
			saved_stats.levelsPassed = new_level_passed
		
		saved_stats.levels[level_name] = savind_stats #добавляем туда статистику
		save_stats(saved_stats)


func goto_scene(path, loading = false): # game requests to switch to this scene
	load_game = loading
	if path == "MainMenu":
		current_scene.queue_free()
		current_scene = main_menu
		main_menu.checkStats()
		main_menu._update_down_label()
		main_menu.visible = true
		get_tree().paused = false
		paused = false
	else:
		if current_scene != main_menu:
			current_scene.queue_free() # get rid of the old scene
		else:
			current_scene = null #если выходим из менюшки, оставляем её на фоне
			main_menu.visible = false
			main_menu.updating_down_label = false
		
		get_node("LoadingMenu").visible = true
		get_node("LoadingMenu")._change_interface_language()
		
		yield(get_tree(),"idle_frame")
		
		loader = ResourceLoader.load_interactive(path)
		if loader == null: # check for errors
			print("loader is null wtf")
			return
		set_process(true)
		
		wait_frames = 1


func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	
	if load_equipment:
		var player = get_node("/root/Main/Player")
		if G.saved_coat:
			G.saved_coat = false
			player.have_coat = true
		
		for equip in saved_equipment:
			player.equipment[equip] = true
		
	load_equipment = false
	
	settings = get_node("/root/Main/canvas/PauseMenu/SettingsMenu")
	if settings:
		settings.loadInterface()
		settings.loadSettingsFromGame()
	if load_game:
		var loading = get_node("/root/Main/loadingManager")
		if loading:
			loading.loadGame()
		load_game = false


func setPause(object, pause: bool, pause_music = true):
	if pause_music:
		pause_music = pause
	music_paused = pause_music
	
	if pause:
		if !paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			paused = true
		else:
			print(object.name + " tried to pause paused game")
	else:
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			paused = false
		else:
			print(object.name + " tried to unpause unpaused game")


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	main_menu = current_scene


func _process(delta):
	if loader == null:
		set_process(false)
		return
	
	if wait_frames > 0: # wait for frames to let the "loading" animation show up
		wait_frames -= 1
		return
	
	# poll your loader
	var err = loader.poll()
	
	if err == ERR_FILE_EOF: # Finished loading.
		get_node("LoadingMenu").visible = false
		var resource = loader.get_resource()
		loader = null
		set_new_scene(resource)
	elif err != OK: # error during loading
		if G.english:
			get_node("LoadingMenu/Label").text = "There is some error in loading. Try again - maybe it'll work"
		else:
			get_node("LoadingMenu/Label").text = "Произошла какая-то ошибка во время загрузки. Попробуй еще раз - может, загрузит"
		loader = null
	
	yield(get_tree(),"idle_frame")

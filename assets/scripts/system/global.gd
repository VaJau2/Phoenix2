extends Node

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
var game_over = false

var settings
var distance = 600 #настройки, которые сохраняются в settingsMenu
var sensivity = 0.1 #и потом берутся в player
var reflections = 200

var load_game = false

var scores = 0
var saved_equipment = []
var saved_coat = false
var load_equipment = false


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


func setPause(object, pause: bool):
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
		get_node("LoadingMenu/Label").text = "Произошла какая-то ошибка во время загрузки. Попробуй еще раз - может, загрузит"
		loader = null
	
	yield(get_tree(),"idle_frame")

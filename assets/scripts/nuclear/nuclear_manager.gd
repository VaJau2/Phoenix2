extends Spatial

onready var messages = get_node("/root/Main/canvas/messages")
onready var after = get_node("/root/Main/Player/after")

var increase_speed = 0.5
var warStarted = false
var noise = false
var bombs = []

onready var noiseTexture = get_node("/root/Main/canvas/noise/texture")
onready var noiseAnim = get_node("/root/Main/canvas/noise/anim")

onready var environment = get_node("/root/Main/env")
var ambient_energy #0.5
var ambient_color #10142f
var fog_color #1b1b20
var fog_depth_begin #15
var fog_speed = 0

var windows = []

var game_over = false
onready var black_screen = get_node("/root/Main/canvas/black")
onready var records_menu = get_node("/root/Main/canvas/ResultMenu")

func startWar():
	messages.current_task = ["- Выжить?..", "- Survive?.."]
	$alarm.play()
	for bomb in bombs:
		bomb.explode()
	yield(get_tree().create_timer(10, false),"timeout")
		
	warStarted = true
	yield(get_tree().create_timer(11, false),"timeout")
		
	after.play()
	yield(get_tree().create_timer(2, false),"timeout")
	
	noiseAnim.play("noise")
	noise = true
	yield(get_tree().create_timer(3, false),"timeout")

	_brakeWindows()
	yield(get_tree().create_timer(0.5, false),"timeout")
		
	game_over = true

func _increaseShaking(delta):
	if increase_speed > 0:
		G.player.shaking_speed += delta * increase_speed
		increase_speed -= delta * 0.08


func _increaseNoise(delta):
	if noiseTexture.modulate.a < 0.4:
		noiseTexture.modulate.a += 0.004


func _makeSkyRed(delta):
	if ambient_color.r < 0.9:
		ambient_color.r += delta * 0.1
		ambient_energy += delta * 0.1
	environment.set_ambient_light_color(ambient_color)
	environment.set_ambient_light_energy(ambient_energy)
	
	if noise:
		if fog_color.r < 0.9:
			fog_color.r += delta * fog_speed
			fog_depth_begin -= delta * fog_speed
			fog_speed += 0.005
		environment.set_fog_color(fog_color)


func _brakeWindows():
	for window in windows:
		var wr = weakref(window)
		if wr.get_ref():
			window.brake(150)

func _ready():
	for child in get_children():
		if child.name != "alarm":
			bombs.append(child)
	environment = environment.get_environment()
	ambient_color = environment.get_ambient_light_color()
	fog_color = environment.get_fog_color()
	ambient_energy = environment.get_ambient_light_energy()
	fog_depth_begin = environment.fog_depth_begin


func _process(delta):
	if warStarted:
		_increaseShaking(delta)
		_makeSkyRed(delta)
	if noise:
		_increaseNoise(delta)
	if game_over:
		black_screen.visible = true
		if black_screen.color.a < 1:
			black_screen.color.a += delta
		else:
			G.game_over = true
			records_menu.showRecords()
			G.setPause(self, true)

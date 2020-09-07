extends Spatial

#внезапно еще и грузит расу игрока, если игра загружается

var underwater = preload("res://assets/audio/underwater.wav")
var flaskOpen = preload("res://assets/audio/futniture/flaskOpen.wav")
var phrase = preload("res://assets/audio/phrases/speech1-edited.wav")
var phraseText = ["Благодарим за использование нашей экспериментальной системы воскрешения, названной \"Феникс2!\"",
				   "Надеюсь, вы больше не умрете!"]
var phraseTextEng = ["Thank you for using our experimental resurrection system called \"Phoenix2\"!",
					"I hope you won't die again!"]
var textTimers = [4.2, 1.8]
var textI = 0

onready var subs = get_node("/root/Main/canvas/subtitles")

export var startingFlask = false

onready var blackScreen = get_node("/root/Main/canvas/black")
onready var resultMenu = get_node("/root/Main/canvas/ResultMenu")

onready var player = get_node("/root/Main/Player")
onready var camera = get_node("Camera")
onready var head = get_node("Armature/Skeleton/Body002")
onready var hair = get_node("Armature/Skeleton/BoneAttachment/Cube")

onready var audi = get_node("audi")
onready var anim = get_node("AnimationPlayer")
onready var water = get_node("water")
onready var glass = get_node("flas-glass")
onready var body = get_node("Armature")

var temp_delta = 0.1


func _ready():
	var saved_stats = resultMenu.load_stats()
	if saved_stats != null:
		if "Training" in saved_stats:
			if G.race != int(saved_stats.Race):
				G.race = int(saved_stats.Race)
				G.player.loadRace()
	
	anim.current_animation = "idle"
	
	if G.race != 1:
		get_node("Armature/Skeleton/BoneAttachment 2/horn").visible = false
	if G.race != 2:
		get_node("Armature/Skeleton/WingL").visible = false
		get_node("Armature/Skeleton/WingR").visible = false
	
	if startingFlask:
		player.camera = player.get_node("Rotation_Helper/Camera")
		player.rotation_helper_third = player.get_node("Rotation_Helper_Third")
		wakeUp()
	else:
		set_process(false)


func wakeUp():
	set_process(true)
	player.teleport_inside = true
	player.rotation_helper_third._setThirdView(false)
	player.rotation_helper_third.mayChange = false
	player.visible = false
	player.mayMove = false
	camera.current = true
	head.set_layer_mask(2)
	hair.set_layer_mask(2)
	if G.race == 1:
		get_node("Armature/Skeleton/BoneAttachment 2/horn").set_layer_mask(2)
	
	player.global_transform.origin = body.global_transform.origin
	player.global_transform.basis = body.global_transform.basis
	player.rotation = Vector3(0, player.rotation.y + 65, 0)
	player.scale = Vector3(1.05,1.05,1.05)
	
	player.OnStairs = false
	if player.crouching:
		player._sit(false)
	
	blackScreen.visible = true
	blackScreen.color.a = 1.0
	player.camera.eyes_closed = true
	
	if startingFlask:
		yield(get_tree().create_timer(0.2),"timeout")
	else:
		yield(get_tree().create_timer(3),"timeout")
	
	player.audi_hitted.stream = underwater
	player.audi_hitted.play()
	
	while(blackScreen.color.a > 0):
		if !G.paused:
			blackScreen.color.a -= 0.1
		yield(get_tree(),"idle_frame")
	
	blackScreen.visible = false
	player.camera.eyes_closed = false
	yield(get_tree().create_timer(1),"timeout")
	
	$wires.visible = false
	talkToPlayer()
	
	yield(get_tree().create_timer(2.5),"timeout")
	
	anim.current_animation = "wakeUp"

	while(water.translation.y > -2):
		if !G.paused:
			water.translation.y -= 0.02
		yield(get_tree(),"idle_frame")
	
	body.queue_free()
	player.visible = true
	player.mayMove = true
	player.rotation_helper_third.mayChange = true
	player.camera.current = true
	
	yield(get_tree().create_timer(0.2),"timeout")
	
	player.audi_hitted.stream = flaskOpen
	player.audi_hitted.play()
	
	while(glass.translation.y > -2):
		if !G.paused:
			glass.translation.y -= 0.05
		yield(get_tree(),"idle_frame")
	
	glass.queue_free()
	water.queue_free()
	$window.queue_free()
	set_process(false)


func talkToPlayer():
	audi.play()
	subs.visible = true
	
	var tempTimers = []
	for timer in textTimers:
		tempTimers.append(timer)
	
	while(textI < phraseText.size()):
		if G.paused:
			yield(get_tree(), "idle_frame")
		else:
			if G.english:
				subs.text = phraseTextEng[textI]
			else:
				subs.text = phraseText[textI]
			if tempTimers[textI] > 0:
				tempTimers[textI] -= temp_delta
				yield(get_tree(), "idle_frame")
			else:
				textI += 1
	subs.visible = false


func _process(delta):
	temp_delta = delta

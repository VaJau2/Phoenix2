extends Control

#--переменые под менюшку
onready var back = get_node("background")
onready var blur = get_node("blur")
var blur_amount = 0

onready var container = get_node("menu/text")
onready var menu_label = get_node("menu/text/Label")
onready var skip = get_node("menu/skip")
var button_prefab = preload("res://objects/interface/dialogue/button_prefab.tscn")

#--переменые под картинки говорящих
onready var leftTalker = get_node("leftTalker")
onready var rightTalker = get_node("rightTalker")
onready var center = get_node("center")

#--переменные под облачко
onready var cloud = get_node("cloud")
onready var arrows = {
	"left": get_node("cloud/arrows/left"),
	"right": get_node("cloud/arrows/right"),
	"up": get_node("cloud/arrows/up"),
}
onready var cloud_label = get_node("cloud/Label")

#--переменные под текущий диалог
var tempNpc = null
var paused = false
var buttons = []
var percentLabels = []

var dialogue_data = {}
var temp_node = 0
var newStage = -1
var new_node = -1
#-2 - выход из менюшки диалогов
#-1 - следующий нод берется из ответов
#>0 - следующий нод

signal textShowed


func _getRace():
	match G.race:
		0: 
			return "earthpony"
		1: 
			return "unicorn"
		2: 
			return "pegasus"


func loadPicture(talker, node_data, side):
	if side in node_data:
		var path = "res://assets/dialogues/sprites/" + node_data[side]
		if "strikely" in path:
			path +=  "/" + _getRace()
		path += ".png"
		talker.texture = load(path)
		talker.visible = true
	else:
		talker.texture = null
		talker.visible = false


func loadEffects(effects):
	if effects:
		var has_left = false
		var has_right = false
		
		for effect in effects:
			if effect.begins_with("left"):
				has_left = true
				var clear_effect = effect.lstrip("left-")
				leftTalker.effects[clear_effect] = float(effects[effect])
			
			elif effect.begins_with("right"):
				has_right = true
				var clear_effect = effect.lstrip("right-")
				rightTalker.effects[clear_effect] = float(effects[effect])
		
		if !has_left:
			leftTalker.clearEffects()
		if !has_right:
			rightTalker.clearEffects()
	else:
		leftTalker.clearEffects()
		rightTalker.clearEffects()


func _setArrows(side):
	for arrow in arrows:
		arrows[arrow].visible = false
	arrows[side].visible = true


func _clearButtons():
	buttons.clear()
	if container.get_child_count() > 1:
		for child in container.get_children():
			if child != menu_label:
				child.queue_free()


func _spawnButton(text, tonode):
	var new_button = button_prefab.instance()
	new_button.text = WordFilter.parse_text(text)
	new_button.connect("pressed", self, "changeNode", [int(tonode)])
	container.add_child(new_button)
	buttons.append(new_button)


func _setPercentText(label, text):
	percentLabels.append(label)
	label.text = WordFilter.parse_text(text)
	label.percent_visible = 0
	var one_percent = 1 / float(label.text.length())
	
	while(label.percent_visible < 1.0):
		if !paused:
			label.percent_visible += one_percent
		yield(get_tree().create_timer(0.02),"timeout")
	
	percentLabels.erase(label)
	if percentLabels.size() == 0:
		skip.visible = true
	emit_signal("textShowed")


func changeNode(tonode):
	if !paused:
		new_node = -1
		temp_node = tonode
		loadNode()


func loadNode():
	skip.visible = false
	var node_data = dialogue_data[str(temp_node)]
	
	loadPicture(leftTalker, node_data, "left")
	loadPicture(rightTalker, node_data, "right")
	if "center" in node_data:
		pass
	loadPicture(center, node_data, "center")
	
	if "effects" in node_data:
		loadEffects(node_data.effects)
	else:
		leftTalker.clearEffects()
		rightTalker.clearEffects()
	
	#грузим игровой текст
	if "text" in node_data:
		menu_label.visible = true
		_setPercentText(menu_label, node_data.text)
	else:
		menu_label.visible = false
		menu_label.text = ""
	
	#грузим фразу в облаке
	if "phrase" in node_data:
		cloud.visible = true
		_setArrows(node_data.phrase[0])
		_setPercentText(cloud_label, node_data.phrase[1])
	else:
		cloud.visible = false
		cloud_label.text = ""
	_clearButtons()
	
	yield(self, "textShowed")
	
	if "newStage" in node_data:
		newStage = int(node_data.newStage)
	else:
		newStage = -1
	
	if "answers" in node_data:
		skip.visible = false
		for answer in node_data.answers:
			_spawnButton(answer[0], answer[1])
	
	elif "tonode" in node_data:
		new_node = int(node_data.tonode)
	else:
		new_node = -2


func loadDialogueData(path):
	var data_file = File.new()
	assert(data_file.open(path, File.READ) == OK, "couldn't open " + path)
	var data_text = data_file.get_as_text()
	data_file.close()
	dialogue_data = parse_json(data_text)


func startDialogue(path, npc = null):
	tempNpc = npc
	G.player.mayMove = false
	visible = true
	while(back.color.a < 0.8 && blur_amount < 5):
		back.color.a += 0.1
		blur_amount += 0.5
		blur.material.set_shader_param("blur_amount", blur_amount)
		yield(get_tree(),"idle_frame")
	$menu.visible = true
	leftTalker.visible = true
	rightTalker.visible = true
	
	G.setPause(self, true, false)
	loadDialogueData(path)
	temp_node = 0
	loadNode()


func finishDialogue():
	visible = false
	G.setPause(self, false, false)
	G.player.mayMove = true
	$menu.visible = false
	cloud.visible = false
	center.visible = false
	leftTalker.visible = false
	rightTalker.visible = false
	blur_amount = 0
	back.color.a = 0
	
	if tempNpc:
		tempNpc.isTalking = false
		if newStage != -1:
			tempNpc.changeDialogueStage(newStage)
	
	G.player.blockJump = true
	yield(get_tree().create_timer(0.5),"timeout")
	G.player.blockJump = false


func _input(event):
	if visible:
		if Input.is_action_just_pressed("ui_cancel"):
			paused = !paused
		
		if !paused && Input.is_action_pressed("jump"):
			if percentLabels.size() > 0:
				for label in percentLabels:
					label.percent_visible = 1
			
			elif new_node == -2:
				finishDialogue()
			
			elif new_node != -1:
				changeNode(new_node)
		
		if event is InputEventKey && buttons.size() > 0:
			for i in range(buttons.size()):
				if event.scancode == i + 49:
					buttons[i].emit_signal("pressed")


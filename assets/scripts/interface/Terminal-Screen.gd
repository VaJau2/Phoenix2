extends Control


var message_button_prefab = preload("res://objects/interface/message-button.tscn")
var owner_name: String
var messages: Dictionary

var menu_num = 0
onready var menus = [
	{
		"menu": get_node("interface/main_menu"),
		"label-text": get_node("interface/main_menu/label-text"),
		"label-text2": get_node("interface/main_menu/label-text2"),
		"container": get_node("interface/main_menu/VBoxContainer")
	},
	{
		"menu": get_node("interface/message"),
		"back": get_node("interface/message/back"),
		"message-header": get_node("interface/message/message-header"),
		"textLabel": get_node("interface/message/scroll/textLabel"),
	},
	{
		"label-header": get_node("interface/label-header"),
		"label-border": get_node("interface/label-border")
	}
]
signal label_changed


func _change_label(label):
	label.percent_visible = 0
	while(label.percent_visible < 1):
		label.percent_visible += 0.1
		yield(get_tree().create_timer(0.02),"timeout")
	emit_signal("label_changed")


func setTerminalOn(terminal):
	owner_name = terminal.owner_name
	messages = terminal.messages
	
	menus[0]["label-text"].text = "Добро пожаловать, " + owner_name
	
	for message_name in messages:
		var new_button = message_button_prefab.instance()
		new_button.name = str(menus[0].container.get_child_count())
		menus[0].container.add_child(new_button)
		new_button.text = "- " + message_name
		new_button.connect("pressed", self, "readMessage", [message_name])
	
	G.setPause(self, true)
	visible = true
	
	menus[0].menu.visible = true
	
	_change_label(menus[2]["label-header"])
	menus[2]["label-header"].visible = true
	yield(self, "label_changed")
	
	_change_label(menus[2]["label-border"])
	menus[2]["label-border"].visible = true
	yield(self, "label_changed")
	
	yield(get_tree().create_timer(0.25),"timeout")
	
	menu_num = 0
	setMenuOn()


func setMenuOn():
	menus[menu_num].menu.visible = true
	
	if !visible:
		setTerminalOff()
		return
	
	for i in range(1, menus[menu_num].keys().size()):
		var key = menus[menu_num].keys()[i]
		
		if "percent_visible" in menus[menu_num][key]:
			_change_label(menus[menu_num][key])
			menus[menu_num][key].visible = true
			yield(self, "label_changed")
		else:
			menus[menu_num][key].visible = true
	
	if !visible:
		setTerminalOff()


func readMessage(message_num):
	$audi.play()
	yield(get_tree().create_timer(0.1),"timeout")
	
	for menu in menus[menu_num]:
		menus[menu_num][menu].visible = false
	menu_num = 1
	
	var formatted_message = messages[message_num].replace("_", "\n")
	menus[1]["message-header"].text = message_num
	menus[1]["textLabel"].text = formatted_message
	
	setMenuOn()


func _on_back_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.1),"timeout")
	menus[1]["textLabel"].text = ""
	for menu in menus[menu_num]:
		menus[menu_num][menu].visible = false
	menu_num = 0
	setMenuOn()


func setTerminalOff():
	visible = false
	for menu in menus[menu_num]:
		menus[menu_num][menu].visible = false
	for child in menus[0].container.get_children():
		child.queue_free()


func _process(delta):
	if visible:
		if Input.is_action_just_pressed("ui_cancel"):
			setTerminalOff()

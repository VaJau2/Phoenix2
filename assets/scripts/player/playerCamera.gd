extends Camera

#скрипт взаимодействия с предметами
#внезапно управляет перемещением на локацию базы из локации обучения через предмет карты

const RAY_LENGTH = 6
onready var messages = get_node("/root/Main/canvas/messages")
onready var dialogueMenu = get_node("/root/Main/canvas/dialogue")

onready var parent = get_node("../../")

var temp_length
var ray_layer = 3

onready var labelBack = get_node("../../../canvas/openBack")
var label
var closed_timer = 0
var closed_text = "Закрыто"

var temp_object
var onetime = false

var temp_fov = 70
var fov_closing = false
onready var eyePartUp = get_node("../../../canvas/eyesParts/eyeUp")
onready var eyePartDown = get_node("../../../canvas/eyesParts/eyeDown")

var eyes_closed = false


func showHint(text, text_eng=""):
	var actions = InputMap.get_action_list("use")
	var key = OS.get_scancode_string(actions[0].get_scancode())
	if G.english:
		label.text = key + text_eng
	else:
		label.text = key + text
	labelBack.visible = true
	onetime = true


func _ready():
	label = labelBack.get_node("label")
	temp_length = RAY_LENGTH


func _process(delta):
	if closed_timer > 0:
		closed_timer -= delta
		label.text = closed_text
		labelBack.visible = true
	
	if eyes_closed:
		eyePartUp.rect_position.y = -200
		eyePartDown.rect_position.y = 200
	elif fov_closing:
		var closeFov = 42
		if parent.equipment.have_bandage:
			closeFov = 30
		
		if temp_fov > closeFov:
			temp_fov -= delta * 60
			set_fov(temp_fov)
		if eyePartUp.rect_position.y < -220:
			eyePartUp.rect_position.y += delta * 1000
		if eyePartDown.rect_position.y > 220:
			eyePartDown.rect_position.y -= delta * 1000
	else:
		if temp_fov < 70:
			temp_fov += delta * 60
			set_fov(temp_fov)
		if eyePartUp.rect_position.y > -650:
			eyePartUp.rect_position.y -= delta * 1200
		
		if eyePartDown.rect_position.y < 650:
			eyePartDown.rect_position.y += delta * 1200

func _physics_process(delta):
	if closed_timer <= 0:
		if onetime:
			labelBack.visible = false
			onetime = false
		
		var _pos = OS.get_window_size() / 2
		var space_state = get_world().direct_space_state
		var from = project_ray_origin(_pos)
		var to = from + project_ray_normal(_pos) * temp_length
		var result = space_state.intersect_ray(from, to, [G.player], ray_layer)
		if result:
			temp_object = result.collider
			if temp_object is furn_base:
				if temp_object.open:
					showHint(" - закрыть", " - close")
				else:
					showHint(" - открыть", " - open")
			
			elif "have_coat" in temp_object:
				if parent.have_coat && !temp_object.have_coat:
					showHint(" - снять пальто", " - take coat off")
				if !parent.have_coat && temp_object.have_coat:
					showHint(" - надеть пальто", " - put coat on")
			
			elif "maneken" in temp_object.name:
				if temp_object.haveEquip:
					showHint(" - надеть " + temp_object.equpName + "\n (" + str(temp_object.cost) + " очков)", \
					" - put " + temp_object.equpNameEng + " on\n (" + str(temp_object.cost) + " scores)")
				else:
					showHint(" - снять " + temp_object.equpName, " - take " + temp_object.equpNameEng + " off")
			
			elif "weapon_num" in temp_object:
				if temp_object.visible:
					showHint(" - взять оружие", " - take gun")
				elif G.player.weapons.temp_weapon_num == temp_object.weapon_num:
					showHint(" - положить оружие", " - put gun")
			
			elif "terminal" in temp_object.name:
				showHint(" - активировать терминал", " - activate terminal")
			
			elif temp_object.name == "map_to_next_loc":
				showHint(" - закончить обучение\nи отправиться на базу", \
				" - finish training\nand go to base")
			
			elif temp_object is Character:
				if temp_object.isTalking:
					showHint(" - поговорить", " - talk")
		else:
			temp_object = null


func _input(event):
	if event is InputEventKey && Input.is_action_just_pressed("use"):
		if labelBack.visible && closed_timer <= 0 && temp_object:
			if temp_object is furn_base:
				var keys = G.player.stats.my_keys
				closed_timer = temp_object.clickFurn(keys)
				if G.english:
					closed_text = "Closed"
				else:
					closed_text = "Закрыто"
			
			elif "have_coat" in temp_object:
				temp_object.changeCoat()
			
			elif "maneken" in temp_object.name:
				closed_timer = temp_object.changeEquip()
				if G.english:
					closed_text = "Not enough scores"
				else:
					closed_text = "Не хватает очков"
			
			elif "weapon_num" in temp_object:
				if temp_object.visible || G.player.weapons.temp_weapon_num == temp_object.weapon_num:
					temp_object.getWeapon()
			
			elif "terminal" in temp_object.name:
				var menu = get_node("/root/Main/canvas/Terminal-Screen")
				if "owner_name" in temp_object:
					menu.setTerminalOn(temp_object)
				else:
					menu.setTerminalOn()
			
			elif temp_object.name == "map_to_next_loc":
				var equipManager = get_node("/root/Main/props/buildings/equipment")
				equipManager.saveEquip()
				G.goto_scene("res://scenes/Main.tscn")
			
			elif temp_object is Character:
				if temp_object.isTalking && temp_object.dialogue_path.length() > 0:
					dialogueMenu.startDialogue(temp_object.dialogue_path, temp_object)
				
	if !parent.thirdView && event is InputEventMouseButton && event.button_index == 2:
		if event.is_pressed():
			fov_closing = true
			pass
		else:
			fov_closing = false
			pass

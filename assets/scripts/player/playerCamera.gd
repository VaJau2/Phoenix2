extends Camera

#скрипт взаимодействия с предметами
#внезапно управляет перемещением на локацию базы из локации обучения через предмет карты

const RAY_LENGTH = 6
onready var messages = get_node("/root/Main/canvas/messages")
var flutty_onetime = false

onready var parent = get_node("../../")

var temp_length
var ray_layer = 3
var _pos

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


func showHint(text):
	var actions = InputMap.get_action_list("use")
	var key = OS.get_scancode_string(actions[0].get_scancode())
	label.text = key + text
	labelBack.visible = true
	onetime = true


func _ready():
	_pos = OS.get_window_size() / 2
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
	
		var space_state = get_world().direct_space_state
		var from = project_ray_origin(_pos)
		var to = from + project_ray_normal(_pos) * temp_length
		var result = space_state.intersect_ray(from, to, [G.player], ray_layer)
		if result:
			temp_object = result
			if temp_object.collider is furn_base:
				if temp_object.collider.open:
					showHint(" - закрыть")
				else:
					showHint(" - открыть")
			
			elif "have_coat" in temp_object.collider:
				if parent.have_coat && !temp_object.collider.have_coat:
					showHint(" - снять пальто")
				if !parent.have_coat && temp_object.collider.have_coat:
					showHint(" - надеть пальто")
			
			elif "maneken" in temp_object.collider.name:
				if temp_object.collider.haveEquip:
					showHint(" - надеть " + temp_object.collider.equpName + "\n (" + str(temp_object.collider.cost) + " очков)")
				else:
					showHint(" - снять " + temp_object.collider.equpName)
			
			elif "weapon_num" in temp_object.collider:
				if temp_object.collider.visible:
					showHint(" - взять оружие")
				elif G.player.weapons.temp_weapon_num == temp_object.collider.weapon_num:
					showHint(" - положить оружие")
			
			elif "terminal" in temp_object.collider.name:
				showHint(" - активировать терминал")
			
			elif temp_object.collider.name == "map_to_next_loc":
				showHint(" - закончить обучение\nи отправиться на базу")
		
			elif "Fluttershy" in temp_object.collider.name && !flutty_onetime:
				showHint(" - получить дополнительные\nочки за просто так")
			
			elif temp_object.collider is Enemy && "collared" in temp_object.collider:
				if temp_object.collider.collared:
					showHint(" - попробовать снять\nбраслет")
				elif temp_object.collider.waiting:
					showHint(" - позвать за собой")
				else:
					showHint(" - сказать ждать здесь")
		else:
			temp_object = null


func _input(event):
	if event is InputEventKey && Input.is_action_just_pressed("use"):
		if labelBack.visible && closed_timer <= 0 && temp_object:
			
			if temp_object.collider is furn_base:
				var keys = G.player.stats.my_keys
				closed_timer = temp_object.collider.clickFurn(keys)
				closed_text = "Закрыто"
			
			elif "have_coat" in temp_object.collider:
				temp_object.collider.changeCoat()
			
			elif "maneken" in temp_object.collider.name:
				closed_timer = temp_object.collider.changeEquip()
				closed_text = "Не хватает очков"
			
			elif "weapon_num" in temp_object.collider:
				if temp_object.collider.visible || G.player.weapons.temp_weapon_num == temp_object.collider.weapon_num:
					temp_object.collider.getWeapon()
			
			elif "terminal" in temp_object.collider.name:
				var menu = get_node("/root/Main/canvas/Terminal-Screen")
				if "owner_name" in temp_object.collider:
					menu.setTerminalOn(temp_object.collider)
				else:
					menu.setTerminalOn()
			
			elif temp_object.collider.name == "map_to_next_loc":
				var equipManager = get_node("/root/Main/props/buildings/equipment")
				equipManager.saveEquip()
				G.goto_scene("res://scenes/Main.tscn")
			
			elif "Fluttershy" in temp_object.collider.name && !flutty_onetime:
				flutty_onetime = true
				if G.race == 0:
					G.scores += 250
					messages.ShowMessage("250 очков получено", 1)
				else:
					messages.ShowMessage("только для земнопони :P", 1)
					yield(get_tree().create_timer(2),"timeout")
					messages.ShowMessage("ладно, раз ты умудрился сюда попасть,\nто заслуживаешь эти очки", 2)
					yield(get_tree().create_timer(2.5),"timeout")
					G.scores += 250
					messages.ShowMessage("250 очков получено", 1)
			
			elif temp_object.collider is Enemy && "collared" in temp_object.collider:
				if temp_object.collider.collared: #--освобождаем
					if "prison_key" in G.player.stats.my_keys:
						temp_object.collider.changeCollar(false)
					else:
						closed_timer = 1
						closed_text = "Нет подходящего ключа"
						
				elif temp_object.collider.waiting: #--следуй за мной
					temp_object.collider.waiting = false
					
				else:  #--жди здесь
					temp_object.collider.waiting = true
					temp_object.collider.set_state("idle")
				
	if !parent.thirdView && event is InputEventMouseButton && event.button_index == 2:
		if event.is_pressed():
			fov_closing = true
			pass
		else:
			fov_closing = false
			pass

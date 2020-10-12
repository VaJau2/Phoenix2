extends Control

onready var manager = get_node('/root/Main/props/buildings/equipment')
signal label_changed

var menu_text_eng = [
	"---STABLE-TEC (ТМ)   INFORMATION TERMINAL---",
	"> Scores count:",
	"> Reserved equipment:",
	"> Get scores by passing tests;",
	"> After completing the training, the points received will be added to\nfinal level scores",
	"> To exit press Esc"
]

func _change_interface_language():
	$"interface/label-header".text = menu_text_eng[0]
	$"interface/label-scores".text = menu_text_eng[1]
	$"interface/label-equipment".text = menu_text_eng[2]
	$"interface/label-info".text = menu_text_eng[3]
	$"interface/label-info2".text = menu_text_eng[4]
	$"interface/label-info3".text = menu_text_eng[5]


func _change_label(label):
	label.percent_visible = 0
	while(label.percent_visible < 1):
		label.percent_visible += 0.1
		yield(get_tree().create_timer(0.02),"timeout")
	emit_signal("label_changed")


func loadEquipment():
	var equipLabel = get_node("interface/eqipment")
	if manager.reservedEqup.size() > 0:
		equipLabel.text = ""
		for equip in manager.reservedEqup:
			if G.english:
				equipLabel.text += equip.equpNameEng + " - " + str(equip.cost) + "\n"
			else:
				equipLabel.text += equip.equipNameTerminal + " - " + str(equip.cost) + "\n"
	else:
		if G.english:
			equipLabel.text = "none"
		else:
			equipLabel.text = "нет"
	equipLabel.visible = true


func setTerminalOn():
	G.setPause(self, true, false)
	visible = true
	
	if G.english:
		_change_interface_language()
	
	_change_label($"interface/label-header")
	$"interface/label-header".visible = true
	yield(self, "label_changed")
	
	_change_label($"interface/label-border")
	$"interface/label-border".visible = true
	yield(self, "label_changed")
	
	yield(get_tree().create_timer(0.25),"timeout")
	
	if !visible:
		setTerminalOff()
		return
	
	_change_label($"interface/label-scores")
	$"interface/label-scores".visible = true
	yield(self, "label_changed")
	
	$"interface/scores".text = str(G.scores)
	$"interface/scores".visible = true
	
	_change_label($"interface/label-equipment")
	$"interface/label-equipment".visible = true
	yield(self, "label_changed")
	
	loadEquipment()
	
	_change_label($"interface/label-border2")
	$"interface/label-border2".visible = true
	yield(self, "label_changed")
	
	yield(get_tree().create_timer(0.25),"timeout")
	
	if !visible:
		setTerminalOff()
		return
	
	_change_label($"interface/label-info")
	$"interface/label-info".visible = true
	yield(self, "label_changed")
	
	_change_label($"interface/label-info2")
	$"interface/label-info2".visible = true
	yield(self, "label_changed")
	
	_change_label($"interface/label-info3")
	$"interface/label-info3".visible = true
	yield(self, "label_changed")
	
	if !visible:
		setTerminalOff()


func setTerminalOff():
	visible = false
	$"interface/label-header".visible = false
	$"interface/label-border".visible = false
	$"interface/label-scores".visible = false
	$"interface/scores".visible = false
	$"interface/label-equipment".visible = false
	$"interface/eqipment".visible = false
	$"interface/label-border2".visible = false
	$"interface/label-info".visible = false
	$"interface/label-info2".visible = false
	$"interface/label-info3".visible = false


func _process(delta):
	if visible:
		if Input.is_action_just_pressed("ui_cancel"):
			setTerminalOff()

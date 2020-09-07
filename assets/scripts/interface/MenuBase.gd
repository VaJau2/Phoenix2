extends Control

onready var down_label = get_node("down_label")
var updating_down_label = false
var down_added = false


func _update_down_label():
	updating_down_label = true
	while(self && updating_down_label):
		down_added = !down_added
		if down_added:
			down_label.text += "_"
		else:
			down_label.text = down_label.text.replace("_","")
		yield(get_tree().create_timer(0.6),"timeout")


func _change_down_label():
	down_label.percent_visible = 0
	while(down_label.percent_visible < 1):
		down_label.percent_visible += 0.1
		yield(get_tree().create_timer(0.01),"timeout")


func _on_mouse_entered(message, english_message):
	if G.english:
		down_label.text = english_message
	else:
		down_label.text = message
	
	if down_added:
		down_label.text += "_"
	_change_down_label()


func _on_mouse_exited():
	down_label.text = ""
	if down_added:
		down_label.text += "_"

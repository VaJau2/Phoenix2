extends Area

var my_lights = []
var lightI = 0
var my_lamps = []
var lampI = 0

var on_light = false

func _on_lightsCheck_body_entered(body):
	if "Light" in body.name:
		if body.get_node("lightSource") && !body.get_node("lightSource").broken:
			on_light = true
			my_lights.append(body)
	if "lamp" in body.name:
		if !body.broken:
			on_light = true
			my_lamps.append(body)

func _on_lightsCheck_body_exited(body):
	if "Light" in body.name && body in my_lights:
		my_lights.erase(body)
		_checkOff()
	if "lamp" in body.name && body in my_lamps:
		my_lamps.erase(body)
		_checkOff()

func _checkOff():
	if my_lights.size() == 0 && my_lamps.size() == 0:
		on_light = false

func _increment(value, array):
	if value < array.size() - 1:
		value += 1
	else:
		value == 0
	return value

func _process(delta):
	if my_lights.size() > 0:
		if my_lights[lightI].get_node("lightSource") == null:
			my_lights.remove(lightI)
			_checkOff()
		_increment(lightI, my_lights)
	else:
		lightI = 0
	
	if my_lamps.size() > 0:
		if my_lamps[lampI] == null || my_lamps[lampI].broken:
			my_lamps.remove(lampI)
			_checkOff()
		_increment(lampI, my_lamps)
	else:
		lampI = 0

extends TextureRect

#TODO
#добпрогать shake-once

const ACCEL = 5
const SPEED = 20
const AMPLITUDE_X = 1
const AMPLITUDE_Y = 3

var shake_x_speed = 0
var shake_y_speed = 0
var shake_x_left = false
var shake_y_up = false

var pos_x_min = 0
var pos_x_max = 0
var pos_y_min = 0
var pos_y_max = 0

var effects = {
	"shake-x": 0,
	"shake-y": 0,
	"shake-x-once": 0,
	"shake-y-once": 0
}


func clearEffects():
	effects = {
		"shake-x": 0,
		"shake-y": 0,
		"shake-x-once": 0,
		"shake-y-once": 0
	}


func _updateShaking(delta):
	if shake_x_speed > 0:
		if shake_x_left:
			if rect_position.x > pos_x_min:
				 rect_position.x -= shake_x_speed * delta * SPEED
			else:
				shake_x_left = false
		else:
			if rect_position.x < pos_x_max:
				 rect_position.x += shake_x_speed * delta * SPEED
			else:
				shake_x_left = true
	
	if shake_y_speed > 0:
		if shake_y_up:
			if rect_position.y > pos_x_min:
				 rect_position.y -= shake_y_speed * delta * SPEED
			else:
				shake_y_up = false
		else:
			if rect_position.y < pos_x_max:
				 rect_position.y += shake_y_speed * delta * SPEED
			else:
				shake_y_up = true


func _ready():
	pos_x_max = rect_position.x + AMPLITUDE_X
	pos_x_min = rect_position.x - AMPLITUDE_X
	pos_y_min = rect_position.y - AMPLITUDE_Y
	pos_y_max = rect_position.y + AMPLITUDE_Y


func _process(delta):
	if shake_x_speed != effects["shake-x"]:
		shake_x_speed = G.setValueZero(shake_x_speed, ACCEL, effects["shake-x"], delta)
	if shake_y_speed != effects["shake-y"]:
		shake_y_speed = G.setValueZero(shake_y_speed, ACCEL, effects["shake-y"], delta)
	
	_updateShaking(delta)

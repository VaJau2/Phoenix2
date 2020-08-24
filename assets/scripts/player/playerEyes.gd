extends MeshInstance

var open_eyes_material = preload("res://assets/materials/player/player_body.material")
var closed_eyes_material = preload("res://assets/materials/player/player_body_closed_eyes.material")

var open_eyes_smiling = preload("res://assets/materials/player/player_body_smiling.material")
var closed_eyes_smiling = preload("res://assets/materials/player/player_body_smiling_closed_eyes.material")

var open_eyes_shy = preload("res://assets/materials/player/player_body_shy.material")
var closed_eyes_shy = preload("res://assets/materials/player/player_body_shy_closed_eyes.material")

var shy_timer = 0
var smiling = false
var closed = false
var timer = 5


func closeEyes():
	if shy_timer > 0:
		set_surface_material(0,closed_eyes_shy)
	elif smiling:
		set_surface_material(0,closed_eyes_smiling)
	else:
		set_surface_material(0,closed_eyes_material)
	timer = 0.3


func smileOn():
	if shy_timer <= 0 && !smiling:
		if closed:
			set_surface_material(0,closed_eyes_smiling)
		else:
			set_surface_material(0,open_eyes_smiling)
		smiling = true


func smileOff():
	if shy_timer <= 0 && smiling:
		if closed:
			set_surface_material(0,closed_eyes_material)
		else:
			set_surface_material(0,open_eyes_smiling)
		smiling = false


func shyOn():
	shy_timer = 10
	if shy_timer <= 0:
		set_surface_material(0,open_eyes_shy)


func _process(delta):
	if visible:
		if shy_timer > 0:
			shy_timer -= delta
		
		if timer > 0:
			timer -= delta
		else:
			closed = !closed
			if !closed:
				if shy_timer > 0:
					set_surface_material(0,open_eyes_shy)
				elif smiling:
					set_surface_material(0,open_eyes_smiling)
				else:
					set_surface_material(0,open_eyes_material)
				timer = randi() % 3 + 3
			else:
				closeEyes()
				if smiling || shy_timer > 0:
					timer = 0.5
				else:
					timer = 0.15

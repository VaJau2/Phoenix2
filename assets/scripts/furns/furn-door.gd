extends furn_base

export var my_key: String
export var closed_sound: AudioStream
export var open_with_key_sound: AudioStream
export var force_opening = true
export var open_timer = 0.0

var opening = false
var other_side = false

func _setCollision(level):
	set_collision_layer(level)
	if level == 1:
		set_collision_mask(level)
	else:
		set_collision_mask(0)


func _open(key_sound = null, timer = 0, force = false):
	if timer > 0 || open_timer > 0:
		opening = true
	
	var anim_force = null
	other_sided = false
	if force:
		my_key = ""
		if !other_side:
			anim_force = "open-force"
		else:
			anim_force = "open-force-2"
			other_sided = true
	.clickFurn(key_sound, timer, anim_force)
	if open_timer != 0.0:
		yield(get_tree().create_timer(open_timer),"timeout")
	if timer != 0:
		yield(get_tree().create_timer(timer),"timeout")
	if open && force_opening:
		_setCollision(2)
	else:
		_setCollision(1)
	opening = false


func clickFurn(keys = null, timer = 0, force = null):
	if !opening:
		if my_key.length() > 0 && !open:
			if keys != null:
				if typeof(keys) == 19:
					if my_key in keys:
						_open(open_with_key_sound, .5)
						my_key = ""
						return 0
				elif keys == "key_all":
					_open(open_with_key_sound, .5)
					return 0
			$audi.stream = closed_sound
			$audi.play()
			return 0.5
		else:
			_open()
	return 0


func _on_otherside_body_entered(body):
	if body.name == "Player":
		other_side = true


func _on_otherside_body_exited(body):
	if body.name == "Player":
		other_side = false

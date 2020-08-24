extends StaticBody

#базовый класс для интерактивных предметов, которые тыкаются на Е
class_name furn_base

export var openSound: AudioStreamSample
export var closeSound: AudioStreamSample
export var open = false

var other_sided = false #для выбиваемых дверей

func _setOpen(anim, sound, timer = 0): 
	$audi.stream = sound
	$audi.play()
	if timer != 0:
		yield(get_tree().create_timer(timer), "timeout")
	$anim.play(anim)
	open = !open

func clickFurn(open_sound = null, timer = 0, new_anim = null):
	if open:
		if !other_sided:
			_setOpen("close", closeSound, timer)
		else:
			_setOpen("close-2", closeSound, timer)
	else:
		var anim = "open"
		if new_anim != null:
			anim = new_anim
		if open_sound == null:
			_setOpen(anim, openSound, timer)
		else:
			_setOpen(anim, open_sound, timer)

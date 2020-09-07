extends Area

export var key_name: String
export var key_pick_text: String
export var key_pick_text_eng: String

onready var mesh = get_node("mesh")
onready var messages = get_node("/root/Main/canvas/messages")
var sound = preload("res://assets/audio/item/ItemAmmo.wav")

func _process(delta):
	mesh.rotate_y(0.05)

func _on_Item_body_entered(body):
	if body.name == "Player" && G.player.mayMove:
		if messages:
			if G.english:
				if key_pick_text_eng.length() > 0:
					messages.ShowMessage(key_pick_text_eng, 1.5)
			else:
				if key_pick_text.length() > 0:
					messages.ShowMessage(key_pick_text, 1.5)
		body.stats.my_keys.append(key_name)
		
		G.player.audi_hitted.stream = sound
		G.player.audi_hitted.play()
		queue_free()

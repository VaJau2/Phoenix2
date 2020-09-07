extends Area

export var key_name: String

onready var mesh = get_node("mesh")
onready var messages = get_node("/root/Main/canvas/messages")
var sound = preload("res://assets/audio/enemies/slave_traders/collarOff.wav")

func _process(delta):
	mesh.rotate_y(0.05)

func _on_Item_body_entered(body):
	if body.name == "Player":
		if messages:
			if G.english:
				messages.ShowMessage("Picked up the key to the collar", 1.5)
			else:
				messages.ShowMessage("Подобран ключ от браслета", 1.5)
		body.collar.set_visible(false)
		body.collar.slider.set_visible(false)
		
		G.player.audi_hitted.stream = sound
		G.player.audi_hitted.play()
		queue_free()

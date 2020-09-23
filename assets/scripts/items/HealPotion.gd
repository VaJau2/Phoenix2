extends Area

const HEALING = 50

onready var mesh = get_node("mesh")

onready var messages = get_node("/root/Main/canvas/messages")
var sound = preload("res://assets/audio/item/ItemHeal.wav")

func _process(delta):
	mesh.rotate_y(0.05)

func _on_HealPotion_body_entered(body):
	if body.name == "Player":
		if G.player.stats.Health < G.player.stats.HealthMax:
			if G.player.stats.Health + HEALING < G.player.stats.HealthMax:
				G.player.stats.Health += HEALING
			else:
				G.player.stats.Health = G.player.stats.HealthMax
			G.player.audi_hitted.stream = sound
			G.player.audi_hitted.play()
			queue_free()
		else:
			if G.english:
				messages.ShowMessage("Your health is full already", 1.5)
			else:
				messages.ShowMessage("Вы и так здоровы", 1.5)

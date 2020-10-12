extends Area

export var ammoType: String
export var ammoCount = 50

onready var mesh = get_node("mesh")
onready var messages = get_node("/root/Main/canvas/messages")
var sound = preload("res://assets/audio/item/ItemAmmo.wav")

func _process(delta):
	mesh.rotate_y(0.05)

func _on_Item_body_entered(body):
	if body.name == "Player":
		var ammo = G.player.weapons.weaponStats[ammoType+"_ammo"]
		var ammo_max = G.player.weapons.weaponStats[ammoType+"_ammoMax"]
		if ammo >= ammo_max:
			if G.english:
				messages.ShowMessage("Not enough space", 1.5)
			else:
				messages.ShowMessage("Нет места", 1.5)
			return
		
		ammo += ammoCount
		if ammo > ammo_max:
			ammo = ammo_max
		
		G.player.weapons.weaponStats[ammoType+"_ammo"] = ammo
		var ammoLabel = G.player.get_node("gunsManager").ammoLabel
		if G.player.weapons.temp_weapon == ammoType:
			ammoLabel.text = str(ammo)
		G.player.get_node("audi_hitted").stream = sound
		G.player.get_node("audi_hitted").play()
		queue_free()

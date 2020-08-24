extends Area

export var weapon_type: String
export var weapon_num: int
export var ammo_count: int
onready var mesh = get_node("mesh")
var sound = preload("res://assets/audio/item/ItemAmmo.wav")

func _process(delta):
	var wr = weakref(mesh)
	if wr.get_ref():
		mesh.rotate_y(0.05)

func _on_gun_body_entered(body):
	if body.name == "Player" && G.player.mayMove:
		var weapons = G.player.weapons
		if weapons.weaponStats[weapon_type+"_have"]:
			var ammo = weapons.weaponStats[weapon_type+"_ammo"]
			var ammoMax = weapons.weaponStats[weapon_type+"_ammoMax"]
			if ammo >= ammoMax:
				return
			
			ammo += ammo_count
			if ammo > ammoMax:
				ammo = ammoMax
			weapons.weaponStats[weapon_type+"_ammo"] = ammo
			if weapons.temp_weapon == weapon_type:
				weapons.ammoLabel.text = str(ammo)
		else:
			weapons.weaponStats[weapon_type+"_have"] = true
			weapons.changeGun(weapon_num)
			if weapons._isPistol() && !weapons.gunOn:
				weapons._setGunOn(true)
				weapons._activeGunOnModel(true)
				weapons.weaponModels[weapons.temp_weapon + "_off"].visible = false
		G.player.audi_hitted.stream = sound
		G.player.audi_hitted.play()
		queue_free()

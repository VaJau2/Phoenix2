extends StaticBody

export var weapon_num: int
export var ammo: int
export var sript_path: NodePath
export var stop_talking = true
var my_script


func _ready():
	my_script = get_node(sript_path)


func getWeapon(finish = true):
	visible = !visible 
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag").visible = !visible
	var weapon_name = G.player.weapons.weapons[weapon_num]
	G.player.weapons.weaponStats[weapon_name+"_have"] = !visible
	
	if !visible:
		if stop_talking:
			my_script.playerExit(G.player)
		my_script.startTraining()
		G.player.weapons.weaponStats[weapon_name+"_ammo"] = ammo
		G.player.weapons.changeGun(weapon_num)
	else:
		if finish:
			my_script.finishTraining()
		G.player.weapons._setGunOn(false)
		G.player.weapons._activeGunOnModel(false)
		if G.player.weapons._isPistol():
			G.player.weapons.weaponModels[weapon_name + "_off"].visible = false

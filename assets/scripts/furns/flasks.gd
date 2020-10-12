extends Spatial

var corpses = [
	preload("res://objects/props/player_corpses/player_corpse1.tscn"),
	preload("res://objects/props/player_corpses/player_corpse2.tscn")
]
var headlessMaterial = preload("res://assets/materials/player/player_body_headless.material")

onready var enemy_manager = get_node("/root/Main/enemies")
onready var checkLoc = get_node("../../../changeLocs")
onready var dealthScreen = get_node("/root/Main/canvas/DealthMenu")
onready var resultMenu = get_node("/root/Main/canvas/ResultMenu")

onready var flasks = [
	get_node("cloneFlask2"),
	get_node("cloneFlask3"),
	get_node("cloneFlask4"),
	get_node("cloneFlask5"),
	get_node("cloneFlask6"),
]
onready var prisonDoor = get_node("../../../land/buildings/stealth/bars-door")
var key = preload("res://objects/items/key.tscn")

#onready var playerCorpsePos = get_node("/root/Main/props/land/player_corpses")

func dropKey():
	var item = key.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = G.player.global_transform.origin
	item.key_name = "prison_key"
	item.key_pick_text = "Подобран ключ от решетки"
	item.global_transform.origin.y += 1


func checkNewFlask():
	if flasks.size() > 0:
		yield(get_tree().create_timer(1),"timeout")
		
		resultMenu.score_reasons.Clones_survive -= 1
		
		# запрогать выбрасывание оружия
		if G.race == 0:
			G.player.stats.Health = 150
		else:
			G.player.stats.Health = 100
		G.player.stats.redScreen.modulate.a = 0
		G.player.flying = false
		
		if "prison_key" in G.player.stats.my_keys:
			G.player.stats.my_keys.erase("prison_key")
			dropKey()
		
		var randI = randi() % 2
		var new_coprse = corpses[randI].instance()

		for wName in G.player.weapons.weapons:
			if G.player.weapons.weaponStats[wName+"_have"]:
				new_coprse.spawnWeapons.append(wName)
				G.player.weapons.weaponStats[wName+"_have"] = false
		if G.player.weapons.gunOn:
			G.player.weapons._setGunOn(false)
		G.player.weapons.disactiveGunModel()
		G.player.get_node("player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag").set_visible(false)
		G.player.body_follows_camera = false
		
		get_node("/root/Main").add_child(new_coprse)
		if enemy_manager.enemies_count > 2:
			var randX = (randf() - 0.5) * 4
			var randZ = (randf() - 0.5) * 4
			#var cPos = playerCorpsePos.global_transform.origin
			var cPos = G.player.global_transform.origin
			new_coprse.global_transform.origin = Vector3(cPos.x + randX, cPos.y + 0.1, + cPos.z + randZ)
			#enemy_manager.CheckDead()
		else:
			new_coprse.global_transform.origin = G.player.global_transform.origin
		
		new_coprse.rotation = G.player.rotation
		
		if G.player.collar.is_visible():
			G.player.collar.set_visible(false)
			G.player.collar.set_process(false)
			G.player.collar.slider.set_visible(false)
		
		if G.player.stats.headless:
			G.player.collar.setHeadBack()
			
			new_coprse.get_node("player_corpse1/Body").set_surface_material(0, headlessMaterial)
			new_coprse.get_node("player_corpse1/Body002").visible = false
			new_coprse.get_node("player_corpse1/horn").visible = false
			new_coprse.get_node("player_corpse1/Cube").visible = false
			
			G.player.stats.headless = false

		yield(get_tree(),"idle_frame")
		
		G.player.stats.redScreen.modulate.a = 0
		flasks[0].wakeUp()
		flasks.remove(0)
		
		if prisonDoor.open:
			prisonDoor.clickFurn("key_all")
			prisonDoor.my_key = "prison_key"
		
		if checkLoc.current_location.name == "land":
			get_node("../../../land").visible = false
			var bunker = get_node("../..")
			bunker.visible = true
			checkLoc.current_location = bunker
		
		yield(get_tree().create_timer(0.5),"timeout")
		enemy_manager.MakeEveryoneIdle(true)
	else:
		G.game_over = true
		dealthScreen.visible = true
		dealthScreen._update_down_label()
		G.setPause(self, true)

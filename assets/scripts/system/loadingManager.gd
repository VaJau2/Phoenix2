extends Node

#скрипт грузит сохранение перед появлением дракона, после убийства командира

onready var resultMenu = get_node("../canvas/ResultMenu")
var stats = {}


func saveGame():
	stats["scores"] = resultMenu.score_reasons
	
	stats["player"] = {
		"Health": G.player.stats.Health,
		"WeaponStats": G.player.weapons.weaponStats,
		"tempWeapon": G.player.weapons.temp_weapon_num,
	}
	
	stats["enemies"] = {}
	for enemy in get_node("../enemies").get_children():
		if enemy.name != "dragon" && enemy.name != "spawners":
			stats["enemies"][enemy.name] = {
				"Health": enemy.Health,
				"Pos": var2str(enemy.translation),
				"Rot": var2str(enemy.rotation),
				"state": enemy.state
			}
	
	
	var saved_stats = resultMenu.load_stats()
	if saved_stats == null:
		var new_stats = {
			"middle_save": stats
		}
	else:
		saved_stats["middle_save"] = stats
	resultMenu.save_stats(saved_stats)
	
	var label = get_node("/root/Main/canvas/savedLabel")
	label.visible = true
	yield(get_tree().create_timer(1),"timeout")
	label.visible = false


func loadGame():
	var saved_stats = resultMenu.load_stats()
	if saved_stats != null:
		if "middle_save" in saved_stats && saved_stats.middle_save != null:
			var stats = saved_stats.middle_save
			
			var player = get_node("../Player")
			var new_pos = get_node("../player_step2-pos").global_transform.origin
			player.global_transform.origin = new_pos
			player.stats.Health = stats.player.Health
			G.race = int(saved_stats.Race)
			player.weapons.weaponStats = stats.player.WeaponStats
			var tempWeapon = stats.player.tempWeapon
			if tempWeapon != 0:
				player.weapons.changeGun(tempWeapon)
			
			for enemy in get_node("../enemies").get_children():
				if enemy.name != "dragon":
					if enemy.name == "zebra-boss":
						enemy.save = false
						enemy.TakeDamage(100)
					else:
						if enemy.name in stats.enemies:
							var health = stats.enemies[enemy.name].Health
							if health <= 0:
								enemy.queue_free()
							else:
								enemy.Health = stats.enemies[enemy.name].Health
								enemy.translation = str2var(stats.enemies[enemy.name].Pos)
								enemy.rotation = str2var(stats.enemies[enemy.name].Rot)
								enemy.state = stats.enemies[enemy.name].state
						else:
							enemy.queue_free()
			resultMenu.score_reasons = stats["scores"]
			
			get_node("../props/buildings/CP/2floor/door7").my_key = ""
			get_node("../props/buildings/CP/1floor/door").my_key = ""
		
		if "Training" in saved_stats:
			var saved_equipment = saved_stats.Training
			var player = get_node("../Player")
			
			G.scores = saved_stats.Scores
			G.race = int(saved_stats.Race)
			
			if G.player:
				G.player.loadRace()
			
			for equip in saved_equipment:
				if (equip == "have_coat" && saved_equipment[equip]) || G.saved_coat:
					G.saved_coat = false
					player.have_coat = true
					player.body.get_node("Armature/Skeleton/BoneAttachment/hat").visible = true
					player.body.get_node("Armature/Skeleton/coat").visible = true
					continue
				
				get_node("/root/Main/Player").equipment[equip] = saved_equipment[equip]

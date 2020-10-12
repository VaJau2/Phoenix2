extends Node

#скрипт грузит сохранение перед появлением дракона, после убийства командира

onready var messages = get_node("/root/Main/canvas/messages")
onready var resultMenu = get_node("../canvas/ResultMenu")
var stats = {}

func _ready():
	messages.current_task = [" - Найти и устранить офицера зебр",
							" - Find and eliminate the zebra officer"]

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
	
	G.save_level("base_middle", stats)
	
	var saved_text = "Game saved" if G.english else "Игра сохранена"
	messages.ShowMessage(saved_text, 1.5)
	messages.current_task = [" - Уничтожить дракона \n - Выжить",
							" - Kill the dragon \n - Survive"]


func loadGame():
	var saved_stats = G.load_stats()
	if saved_stats != null:
		if "base_middle" in saved_stats.levels && saved_stats.levels.base_middle != null:
			var stats = saved_stats.base_middle
			
			var player = get_node("../Player")
			var new_pos = get_node("../player_step2-pos").global_transform.origin
			player.global_transform.origin = new_pos
			player.stats.Health = stats.player.Health
			G.race = int(saved_stats.race)
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
			
			messages.current_task = [" - Уничтожить дракона \n - Выжить",
									" - Kill the dragon \n - Survive"]
		
		if "Training" in saved_stats.levels:
			var saved_equipment = saved_stats.levels.Training
			var player = get_node("../Player")
			
			G.scores = saved_equipment.saved_scores
			G.race = int(saved_stats.race)
			
			if G.player:
				G.player.loadRace()
			
			for equip in saved_equipment:
				if equip == "saved_scores":
					continue
				
				if (equip == "have_coat" && saved_equipment[equip]) || G.saved_coat:
					G.saved_coat = false
					player.have_coat = true
					player.body.get_node("Armature/Skeleton/BoneAttachment/hat").visible = true
					player.body.get_node("Armature/Skeleton/coat").visible = true
					continue
				
				get_node("/root/Main/Player").equipment[equip] = saved_equipment[equip]

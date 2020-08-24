extends "MenuBase.gd"

var slaveVariants = [
	"Рабы были убиты",
	"Один из рабов был убит",
	"Рабы не были спасены",
	"Один из рабов был спасен",
	"Рабы были спасены"
]

func showMenu():
	_loadRecords()
	visible = true
	_update_down_label()


func _load_stats():
	var load_file = File.new()
	if load_file.file_exists("res://stats.sav"):
		load_file.open_compressed("res://stats.sav", File.READ, File.COMPRESSION_FASTLZ)
		var data = load_file.get_line()
		var stats = parse_json(data)
		load_file.close()
		return stats
	
	load_file.close()
	return null


func _showLevelRecord(level_info, stats, level2 = false):
	level_info.visible = true
	
	match str(stats.race):
		"1": 
			level_info.get_node("race_label").text = "Единорог"
		"2":
			level_info.get_node("race_label").text = "Пегас"
	
	
	level_info.get_node("score_label").text = str(stats.score)
	level_info.get_node("time_label").text = str(stats.time)
	level_info.get_node("Kill_label").text = str(stats.kill)
	level_info.get_node("Stealth_Kill_label").text = str(stats.stealth_kill)
	level_info.get_node("Meat_Kill_label").text = str(stats.meat_kill)
	
	if !level2:
		if stats.silent_assasin != 0:
			level_info.get_node("Silent_Assasin_label").visible = true
	else:
		level_info.get_node("Clones_label").text = str(stats.clones_survive)
		level_info.get_node("Slaves_label").text = slaveVariants[stats.slaves_saved]


func _loadRecords():
	var stats = _load_stats()
	if stats && "Zebra_base" in stats:
		var stats1 = stats.Zebra_base
		if stats1:
			$Level2_label.visible = true
			_showLevelRecord($Level1, stats1)
			if "Laboratory" in stats.keys():
				var stats2 = stats.Laboratory
				_showLevelRecord($Level2, stats2, true)


func CheckZebraLevel():
	var stats = _load_stats()
	if stats && "Zebra_base" in stats:
		var stats1 = stats["Zebra_base"]
		if stats1:
			return true
	return false


func _on_back_pressed():
	visible = false
	updating_down_label = false
	$audi.play()

extends "MenuBase.gd"

var slaveVariants = {
	0:["Рабы были убиты", "The slaves were killed"],
	1:["Один из рабов был убит", "One of the slaves was killed"],
	2:["Рабы не были спасены", "The slaves were not saved"],
	3:["Один из рабов был спасен", "One of the slaves was saved"],
	4:["Рабы были спасены", "The slaves were saved"]
}

var menu_text = {
	0: ["/Phoenix2/Главное_меню/Рекорд", "/Phoenix2/Main_menu/Records"],
	1: ["Уровень не пройден", "The Level is not passed"],
	2: ["[--------------База-зебр------------------]", "[--------------Zebra's-base------------------]"],
	3: ["Раса:", "Race:"],
	4: ["Количество очков:", "Scores count:"],
	5: ["Время прохождения:", "Passage time:"],
	6: ["Убийств:", "Kills:"],
	7: ["Скрытых убийств:", "Stealth kills:"],
	8: ["Кровавых убийств:", "Bloody kills:"],
	9: ["Тревога не была поднята", "The alarm was not raised"],
	10:["[--------------Бункер----------------]", "[--------------Bunker----------------]"],
	11:["               [Назад]", "               [Back]"]
}

func _getMenuText(textI):
	if G.english:
		return menu_text[textI][1]
	else:
		return menu_text[textI][0]


func _change_interface_language():
	$page_label.text = _getMenuText(0)
	$Level1_label.text = _getMenuText(1)
	$Level2_label.text = _getMenuText(1)
	$Level1/level_name.text = _getMenuText(2)
	$Level1/label6.text = _getMenuText(3)
	$Level1/label1.text = _getMenuText(4)
	$Level1/label2.text = _getMenuText(5)
	$Level1/label3.text = _getMenuText(6)
	$Level1/label4.text = _getMenuText(7)
	$Level1/label5.text = _getMenuText(8)
	$Level1/Silent_Assasin_label.text = _getMenuText(9)
	$Level2/level_name.text = _getMenuText(10)
	$Level2/label6.text = _getMenuText(3)
	$Level2/label1.text = _getMenuText(4)
	$Level2/label2.text = _getMenuText(5)
	$Level2/label3.text = _getMenuText(6)
	$Level2/label4.text = _getMenuText(7)
	$Level2/label5.text = _getMenuText(8)
	$back.text = _getMenuText(11)


func showMenu():
	_change_interface_language()
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
		"0":
			if G.english:
				level_info.get_node("race_label").text = "Earthpony"
		"1": 
			if G.english:
				level_info.get_node("race_label").text = "Unicorn"
			else:
				level_info.get_node("race_label").text = "Единорог"
		"2":
			if G.english:
				level_info.get_node("race_label").text = "Pegasus"
			else:
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
		if G.english:
			level_info.get_node("Slaves_label").text = slaveVariants[stats.slaves_saved][1]
		else:
			level_info.get_node("Slaves_label").text = slaveVariants[stats.slaves_saved][0]


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

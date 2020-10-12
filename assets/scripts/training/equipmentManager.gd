extends StaticBody

#скрипт управляет зарезверированным снаряжением
#говорит терминалу, что игрок надел на себя
#снимает это, если у игрока перестает хватать очков

onready var messages = get_node("/root/Main/canvas/messages")
var reservedEqup = []


func calculateSumCost():
	var temp_sum_cost = 0
	for eqip in reservedEqup:
		temp_sum_cost += eqip.cost
	return temp_sum_cost


func addReservedEqip(equip):
	if G.scores >= equip.cost + calculateSumCost():
		reservedEqup.append(equip)
		return true
	return false


func removeReservedEqip(equip = null):
	if equip:
		reservedEqup.erase(equip)
	else:
		var sum_cost = calculateSumCost()
		while sum_cost > G.scores:
			var removingEqip = reservedEqup[reservedEqup.size() - 1]
			removingEqip.changeEquip()
			reservedEqup.erase(removingEqip)
			if G.english:
				messages.ShowMessage("Not enough scores for " + removingEqip.equpNameEng, 1.5)
			else:
				messages.ShowMessage("На " + removingEqip.equpName + " больше не хватает очков", 1.5)
			sum_cost = calculateSumCost()
			yield(get_tree(),"idle_frame")


func getEquipment(equipment_name):
	match equipment_name:
		"бронежилет": 
			return "have_armor"
		"стелс-носки":
			return "have_socks"
		"повязка":
			return "have_bandage"
		"бандана":
			return "have_headrope"


func saveEquip():
	var final_cost = 0
	var equipment_have_stats = {
		"have_armor": false,
		"have_socks": false,
		"have_bandage": false,
		"have_headrope": false,
		"have_coat": false,
		"saved_scores": 0
	}
	
	for eqip in reservedEqup:
		final_cost += eqip.cost
		var equipName = getEquipment(eqip.equipNameTerminal)
		G.saved_equipment.append(equipName)
		if equipName in equipment_have_stats.keys():
			equipment_have_stats[equipName] = true
	
	if G.player.body.get_node("Armature/Skeleton/coat").visible:
		G.saved_coat = true
		equipment_have_stats.have_coat = true
	
	#сохраняем очки, которые игрок заработал и не потратил на снаряжение
	equipment_have_stats.saved_scores = G.scores
	
	G.load_equipment = true
	
	G.save_level("Training", equipment_have_stats, 0, true)
	G.scores = 0

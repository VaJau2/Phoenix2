extends "MenuBase.gd"

export var level_name: String

const SCORES = {
	"Kill": 5,
	"Stealth_Kill": 10,
	"Meat_Kill": 15,
	"Clones_survive": 20,
	"Slaves": 0
}

var slaveVariants = [
	["Рабы были убиты", -200],
	["Один из рабов был убит", -100],
	["Рабы не были спасены", 0],
	["Один из рабов был спасен", 100],
	["Рабы были спасены", 200]
]

var slaveVariantsEng = [
	"The slaves were killed",
	"One of the slaves was killed",
	"The slaves were not saved",
	"One of the slaves was saved",
	"The slaves were saved"
]

const TIME_SCORES = [
	[4, 30, 500], #минуты, секунды, очки
	[6, 5, 300],
	[10, 5, 100],
	[15, 5, 50]
]


var score_reasons = {
	"Kill": 0,
	"Stealth_Kill": 0,
	"Meat_Kill": 0,
	"Clones_survive": 6,
	"Slaves": 2
}

var hours = 0
var minutes = 0
var seconds = 0

func _change_interface_language():
	$page_label.text = "/Phoenix2/Result_menu"
	$Label.text = "[Thank you for playing с:]"
	$label1.text = "Scores count:"
	$label2.text = "Passage time:"
	$label3.text = "Kills:"
	$label4.text = "Stealth kills:"
	$label5.text = "Bloody kills:"
	$label7.text = "Clones survived:"
	$label6.text = "Race:"
	$exit.text = "               [To main menu]"


func save_stats(stats):
	var save_file = File.new()
	save_file.open_compressed("res://stats.sav", File.WRITE, File.COMPRESSION_FASTLZ)
	var data = to_json(stats)
	save_file.store_line(data)
	save_file.close()


func load_stats():
	var load_file = File.new()
	if load_file.file_exists("res://stats.sav"):
		load_file.open_compressed("res://stats.sav", File.READ, File.COMPRESSION_FASTLZ)
		var data = load_file.get_line()
		var stats = parse_json(data)
		load_file.close()
		return stats
	
	load_file.close()
	return null


func showRecords():
	if G.english:
		_change_interface_language()
	
	var scores = G.scores
	for reason in score_reasons.keys():
		scores += score_reasons[reason] * SCORES[reason]
	
	seconds = round(seconds)
	var time = str(hours) + ":" + str(minutes) + ":" + str(seconds)
	$time_label.text = time
	
	if hours == 0:
		for time_score in TIME_SCORES:
			if (minutes < time_score[0] || (minutes == time_score[0] && seconds <= time_score[1])):
				scores += time_score[2]
				break
	
	scores += score_reasons.Clones_survive * SCORES.Clones_survive
	scores += slaveVariants[score_reasons.Slaves][1]
	
	$score_label.text = str(scores)
	
	$Kill_label.text = str(score_reasons.Kill)
	$Stealth_Kill_label.text = str(score_reasons.Stealth_Kill)
	$Meat_Kill_label.text = str(score_reasons.Meat_Kill)
	
	$Clones_label.text = str(score_reasons.Clones_survive)
	
	match G.race:
		1: 
			$race_label.text = "Единорог"
		2:
			$race_label.text = "Пегас"
	
	if G.english:
		$Slaves_label.text = slaveVariantsEng[score_reasons.Slaves]
	else:
		$Slaves_label.text = slaveVariants[score_reasons.Slaves][0]
	
	visible = true
	_update_down_label()
	
	var savind_stats = {
		"race": G.race,
		"score": scores,
		"time": time,
		"kill": score_reasons.Kill,
		"stealth_kill": score_reasons.Stealth_Kill,
		"meat_kill": score_reasons.Meat_Kill,
		"clones_survive": score_reasons.Clones_survive,
		"slaves_saved": score_reasons.Slaves
	}
	
	var saved_stats = load_stats() #грузим предыдущие рекорды
	if saved_stats == null: #если сохранений не было, создаем новые
		var new_stats = {
			level_name: savind_stats
		}
		save_stats(new_stats)
	elif !(level_name in saved_stats) || (saved_stats[level_name].score < scores): #если предыдущий рекорд побит, перезаписываем
		saved_stats[level_name] = savind_stats
		save_stats(saved_stats)


func _count_time(delta):
	seconds += delta
	if seconds > 60:
		seconds = 0
		minutes += 1
		if minutes == 60:
			minutes = 0
			hours += 1


func _process(delta):
	if !G.paused:
		_count_time(delta)


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.2),"timeout")
	G.game_over = false
	G.goto_scene("MainMenu")

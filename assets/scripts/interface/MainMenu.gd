extends "MenuBase.gd"

onready var page_label = get_node("page_label")

signal label_changed


func _change_label(label):
	label.percent_visible = 0
	while(label.percent_visible < 1):
		label.percent_visible += 0.1
		yield(get_tree().create_timer(0.05),"timeout")
	emit_signal("label_changed")


func _ready():
	var settings = get_node("SettingsMenu")
	settings.loadInterface()
	settings.loadSettingsFromFile()
	
	yield(get_tree().create_timer(1),"timeout")
	if randf() < 0.2:
		page_label.text = "...Проснись, Нео..."
		_change_label(page_label)
	else:
		page_label.text = "...Загрузка..."
		_change_label(page_label)
	yield(get_tree().create_timer(1.5),"timeout")
	
	page_label.text = "> Добро пожаловать в Phoenix2! \n> Разработано с использованием Godot Engine \n> загрузка интерфейса..."
	_change_label(page_label)
	
	yield(get_tree().create_timer(2),"timeout")
	
	page_label.text = "/Phoenix2/Главное_меню"
	_change_label(page_label)
	yield(self, "label_changed")
	
	_change_label($Label2)
	$Label2.visible = true
	yield(self, "label_changed")
	
	_change_label($Label)
	$Label.visible = true
	yield(self, "label_changed")
	
	_change_label($Label3)
	$Label3.visible = true
	yield(self, "label_changed")
	
	down_label.visible = true
	$Label5.visible = true
	$start.visible = true
	$load.visible = true
	$settings.visible = true
	$records.visible = true
	$about.visible = true
	$exit.visible = true
	
	checkStats()
	
	_update_down_label()


func checkStats():
	var load_file = File.new()
	var file_exists = load_file.file_exists("res://stats.sav")
	if file_exists:
		$load.disabled = false
	load_file.close()


func _on_start_pressed():
	$audi.play()
	$ChangeRace.visible = true


func _on_settings_pressed():
	$SettingsMenu.visible = true
	$audi.play()


func _on_about_pressed():
	$About.visible = true
	$audi.play()


func _on_back_pressed():
	$About.visible = false
	$ChangeRace.visible = false
	$audi.play()


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.3),"timeout")
	get_tree().quit()


func _on_records_pressed():
	$RecordsMenu.showMenu()
	$audi.play()


func _on_choose_pressed(race):
	G.scores = 0
	G.saved_equipment = []
	if race == "earthpony":
		G.race = 0
	elif race == "unicorn":
		G.race = 1
	elif race == "pegasus":
		G.race = 2
	yield(get_tree().create_timer(0.3),"timeout")
	$ChangeRace.visible = false
	G.goto_scene("res://scenes/Training.tscn")


func _on_load_pressed():
	yield(get_tree().create_timer(0.3),"timeout")
	if $RecordsMenu.CheckZebraLevel():
		G.goto_scene("res://scenes/Laboratory.tscn")
	else:
		G.goto_scene("res://scenes/Main.tscn", true)

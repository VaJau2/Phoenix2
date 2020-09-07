extends "MenuBase.gd"

onready var page_label = get_node("page_label")
onready var chooseLanguage = get_node("chooseLanguage")


var menu_text = {
	0: ["...Проснись, Нео...", "...Wake up, Neo..."],
	1: ["...Загрузка...", "...Loading..."],
	2: ["> Добро пожаловать в Phoenix2! \n> Разработано с использованием Godot Engine \n> загрузка интерфейса...",
		"> Welcome to Phoenix2! \n> Developed using Godot Engine \n> loading interface...",
		],
	3: ["/Phoenix2/Главное_меню", "/Phoenix2/Main_menu"],
	4: ["               [Начать игру]", "               [Start game]"],
	5: ["               [Загрузить]", "               [Load game]"],
	6: ["               [Настройки]", "               [Settings]"],
	7: ["               [Рекорды]", "               [Records]"],
	8: ["               [Об игре]", "               [About]"],
	9: ["               [Выйти]", "               [Exit]"],
	
	10:["/Phoenix2/Главное_меню/Об_игре","/Phoenix2/Main_menu/About_game"],
	11:["Игра разработана в ходе участия в Шестом Общетабунском Конкурсе Игростроения.\n" + \
	"Автор игры: VaJa72\nКомпозитор треков и просто хороший человек: Phelanhik\nОзвучено с использованием сервиса 15.ai\n2020",
	"The game was developed during participation in Sixth OKI.\n" + \
	"Author: VaJa72\nComposer and just a good person: Phelanhik\nVoiced using the service 15.ai\n2020"],
	12:["               [Назад]", "               [Back]"],
	
	13:["/Phoenix2/Главное_меню/Выбор_Расы","/Phoenix2/Main_menu/Choice_of_race"],
	14:["[Земной пони]","[Earthpony]"],
	15:["> Здоровье: 150\n> Возможность\nделать подкаты\n> Возможность\nбегать\n> Сильные удары",
		"> Health: 150\n> Ability to\ndodge\n> Ability to\nrun\n> Strong hits"],
	16:["[Единорог]","[Unicorn]"],
	17:["> Здоровье: 100\n> Возможность\nтелепортации\n> Возможность\nсоздавать\nмагический щит",
		"> Health: 100\n> Ability to\nteleport\n> Ability to\ncreate a\nmagical shield"],
	18:["[Пегас]","[Pegasus]"],
	19:["> Здоровье: 100\n> Возможность\nлетать",
		"> Health: 100\n> Ability to\nfly",]
}

signal label_changed

func _getMenuText(textI):
	if G.english:
		return menu_text[textI][1]
	else:
		return menu_text[textI][0]


func _change_interface_language():
	$start.text = _getMenuText(4)
	$load.text = _getMenuText(5)
	$settings.text = _getMenuText(6)
	$records.text = _getMenuText(7)
	$about.text = _getMenuText(8)
	$exit.text = _getMenuText(9)
	
	$About/page_label.text = _getMenuText(10)
	$About/about_label.text = _getMenuText(11)
	$About/back.text = _getMenuText(12)
	
	$ChangeRace/page_label.text = _getMenuText(13)
	$ChangeRace/back.text = _getMenuText(12)
	$ChangeRace/earthpony/choose.text = _getMenuText(14)
	$ChangeRace/earthpony/Label.text = _getMenuText(15)
	$ChangeRace/unicorn/choose.text = _getMenuText(16)
	$ChangeRace/unicorn/Label.text = _getMenuText(17)
	$ChangeRace/pegasus/choose.text = _getMenuText(18)
	$ChangeRace/pegasus/Label.text = _getMenuText(19)


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
	_change_interface_language()
	settings._change_interface_language()
	
	yield(get_tree().create_timer(1),"timeout")
	
	chooseLanguage.visible = true
	down_label.visible = true
	$Label5.visible = true


func _loadGame():
	_change_interface_language()
	
	down_label.visible = false
	$Label5.visible = false
	
	if randf() < 0.2:
		page_label.text = _getMenuText(0)
		_getMenuText(0)
		_change_label(page_label)
	else:
		page_label.text = _getMenuText(1)
		_change_label(page_label)
	yield(get_tree().create_timer(1.5),"timeout")
	
	page_label.text = _getMenuText(2)
	_change_label(page_label)
	
	yield(get_tree().create_timer(2),"timeout")
	
	page_label.text = _getMenuText(3)
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
	$SettingsMenu._change_interface_language()
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


func _on_language_pressed(english):
	G.english = english
	if english:
		$chooseLanguage/russian.pressed = false
		$chooseLanguage/english.pressed = true
		$chooseLanguage/continue.text = "[Continue]"
		$chooseLanguage/chooseLabel.text = "Choose language"
	else:
		$chooseLanguage/english.pressed = false
		$chooseLanguage/russian.pressed = true
		$chooseLanguage/continue.text = "[Продолжить]"
		$chooseLanguage/chooseLabel.text = "Выберите язык"


func _on_chooseLang_continue_pressed():
	$chooseLanguage.visible = false
	_loadGame()

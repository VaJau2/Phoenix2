extends Area

var phrase_2 = {
	"instructions": preload("res://assets/audio/phrases/instructions/instructions2.ogg"),
	"instructions_text": [
		"Итак, вы готовы к миссии?",
		"Место, в которое вас отправят, обозначено на карте с помощью красного маркера",
		"Сделайте дыру в заборе, чтобы пройти через неё на базу",
		"Офицер находится в здании по центру карты",
		"Скорее всего, входная дверь будет закрыта, но ключ от неё должен быть неподалеку",
		"Устраните его любым выбранным способом и покиньте базу",
		"Удачи"
	],
	"instructions_timers": [
		3.3, 
		4.2,
		3.0,
		2.6,
		4.5,
		2.7,
		0.7
	],
}

onready var twilight = get_node("../MrHandy-Twilight")
var start_wait = false
var timer_wait = 5


func _changePhrase(phrase_name):
	twilight.phrase = phrase_2[phrase_name]
	twilight.phraseText = phrase_2[phrase_name + "_text"]
	twilight.textTimers = phrase_2[phrase_name + "_timers"]
	twilight.textI = 0


func _ready():
	yield(get_tree().create_timer(1),"timeout")
	twilight.talkToPlayer()
	yield(twilight,"finished")
	start_wait = true
	_changePhrase("instructions")


func _process(delta):
	if start_wait:
		if timer_wait > 0:
			timer_wait -= delta
		else:
			start_wait = false


func _on_passArea_body_exited(body):
	twilight.stopTalking()


func _on_passArea_body_entered(body):
	if body.name == "Player":
		if timer_wait <= 0:
			twilight.talkToPlayer()

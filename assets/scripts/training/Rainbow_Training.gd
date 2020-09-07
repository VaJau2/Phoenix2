extends "TrainingBase.gd"

const PASS_SCORES = 8
onready var messages = get_node("/root/Main/canvas/messages")
onready var eqipManager = get_node("../../equipment")

export var startRingPath: NodePath
var startRing

var player_starting = false
var start_timer = 1.5

var increase = 1
var got_scores = 0

var ringFly1 = preload("res://assets/audio/flying/flyingRing1.wav")
var ringFly2 = preload("res://assets/audio/flying/flyingRing2.wav")
var failSound = preload("res://assets/audio/futniture/stealth_fail.wav")

func _ready():
	startRing = get_node(startRingPath)
	mrHandy = get_node("../MrHandy-Rainbow")
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/flight/flight-greetings.ogg"),
		"greetings_text": [
			"Приветствую на летном поле, пегас!",
			"Сегодня мы проверим твои летные способности",
			"Если хочешь прослушать инструкции, кивни один раз."
		],
		"greetings_text_eng": [
			"Welcome to the flying field, pegasus!",
			"Today we are gonna check your flying skills!",
			"If you wish to listen my instructions, nod one time."
		],
		"greetings_timers": [2.9, 3.1, 3.3],
		
		
		"not_pegasus": preload("res://assets/audio/phrases/instructions/flight/flying-non-pegasus.ogg"),
		"not_pegasus_text": ["Только для пегасов, извини"],
		"not_pegasus_text_eng": ["Only for pegasuses, sorry."],
		"not_pegasus_timers": [2.8],
		
		
		
		"instructions": preload("res://assets/audio/phrases/instructions/flight/flight-instructions.ogg"),
		"instructions_text": [
			"Внимание, пегас!",
			"Для успешных полетов во время сражения запомни",
			"не врезайся!",
			"Это правило звучит просто,",
			"но на практике почти половина пегасов проигрывают свои сражения из-за своей невнимательности во время полета",
			"Чем дольше твой полет направлен вперед, тем быстрее ты будешь лететь, тем меньше твоя маневренность",
			"Если бы это была гонка, от тебя ничего больше бы не требовалось,",
			"но в сражении необходим баланс между скоростью и маневренностью",
			"Никогда не забывай это.",
		],
		"instructions_text_eng": [
			"Attention, pegasus!",
			"For a successful flight during the combat remember",
			"don't crash!",
			"This rule sounds easy,",
			"but in practice almost half of all pegasuses losing their combats because of their carelessness during the flight.",
			"As long as your flight is directed forward, the faster you fly, the less your maneuverability.",
			"If it was a race, nothing more would be required of you,",
			"but the battle requires a balance between speed and maneuverability.",
			"Never forget about this."
		],
		"instructions_timers": [
			2.0,
			3.0,
			2.5,
			2.3,
			6.0,
			5.8,
			4.0,
			3.6,
			1.8
		],
		
		"try": preload("res://assets/audio/phrases/instructions/flight/flight-try.ogg"),
		"try_text": ["Если хочешь пролететь полосу препятствий, подойти к стартовой линии.",],
		"try_text_eng": ["If you wish to fly the obstacle course, go to the start line.",],
		"try_timers": [
			2.9,
		],
		
		"fail": preload("res://assets/audio/phrases/instructions/flight/flight-fail.ogg"),
		"fail_text": ["Неудача, попробуй еще раз."],
		"fail_text_eng": ["Fail, try again."],
		"fail_timers": [1.8],
		
		"succeed": preload("res://assets/audio/phrases/instructions/flight/flight-succeed.ogg"),
		"succeed_text": ["Отлично, ты почти такой же потрясный летун, как пони, с которой скопирован мой голос!"],
		"succeed_text_eng": ["Great, you are as awesome flyer as pony, which my voice was copied from!"],
		"succeed_timers": [4.8]
	}


func startTraining():
	is_training = true
	startRing.start()
	if got_scores > 0:
		if G.english:
			messages.ShowMessage("Reset:" + str(got_scores) + " scores", 1.5)
		else:
			messages.ShowMessage(str(got_scores) + " очков сброшено", 1.5)
		G.scores -= got_scores
		got_scores = 0
		eqipManager.removeReservedEqip()
	
	increase = 1


func finishTraining():
	is_training = false
	got_scores = int(increase * PASS_SCORES)
	if G.english:
		messages.ShowMessage("Got:" + str(got_scores) + " scores", 1.5)
	else:
		messages.ShowMessage(str(got_scores) + " очков получено", 1)
	G.scores += got_scores
	G.player.audi_hitted.stream = ringFly2
	G.player.audi_hitted.play()
	
	if mrHandy.Health > 0:
		_changePhrase("succeed")
		yield(get_tree().create_timer(0.1),"timeout")
		yield(mrHandy,"finished")
		_changePhrase("greetings", false)


func loseTraining():
	is_training = false
	G.player.audi_hitted.stream = failSound
	G.player.audi_hitted.play()
	
	if mrHandy.Health > 0:
		_changePhrase("fail", false)
		last_phrase = true
		yield(get_tree().create_timer(0.1),"timeout")
		yield(mrHandy, "finished")
		_changePhrase("greetings", false)
		last_phrase = false


func _on_passArea_body_exited(body):
	playerExit(body)


func _on_passArea_body_entered(body):
	if !is_training:
		playerEnter(body, 2, "not_pegasus")


func _on_startArea_body_entered(body):
	if !is_training && body.name == "Player" && G.race == 2:
		player_starting = true


func _on_startArea_body_exited(body):
	if !is_training && body.name == "Player" && G.race == 2:
		player_starting = false
		start_timer = 1.5


func _input(event):
	checkingNod(event)


func _process(delta):
	if timer > 0:
		timer -= delta
	
	if !is_training && player_starting:
		if start_timer > 0:
			start_timer -= delta
		else:
			start_timer = 1.5
			player_starting = false
			playerExit(G.player)
			startTraining()

extends "TrainingBase.gd"

var pistol_phrase_told = false
var roboEyes_count = 5

var got_scores = 0

onready var pistol = get_node("../table/pistol")
onready var messages = get_node("/root/Main/canvas/messages")
onready var eqipManager = get_node("../../equipment")

onready var applejack_training = get_node("../../shooting/passArea")

func _ready():
	mrHandy = get_node("../MrHandy-Pinkie")
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/stealth/strealth-greetings.ogg"),
		"greetings_text": [
			"Приветствую, агент!",
			"Если вы хотите прослушать инструкции о скрытности, кивните один раз"
		],
		"greetings_text_eng": [
			"Greetings, agent!",
			"If you wish to hear my stealth instructions, nod one time."
		],
		"greetings_timers": [1.7, 3.3],
		
		
		"instructions": preload("res://assets/audio/phrases/instructions/stealth/stealth-instruction1.ogg"),
		"instructions_text": [
			"Отлично",
			"Самое главное в том, чтобы стать незаметным - пригнуться и двигаться тише",
			"Для этого нажмите левый control (или что там у вас настроено)",
			"Когда вы находитесь в этом положении, у вас на экране появляется индикатор обнаружения",
			"Если вы будете двигаться перед лицом противника не пригнувшись, вас тут же заметят",
			"Старайтесь избегать света",
			"Даже если вы будете двигаться пригнувшись, вас быстро заметят, если неподалеку есть лампочка",
			"Но даже если вас заметил один или два противника - не беспокойтесь,",
			"ведь их можно быстро устранить до начала тревоги",
			"Если же вас заметило более трех противников, ваш стелс официально провалился",
			"Старайтесь использовать оружие с глушителем",
			"так как громкие пушки - залог проваленного стелса!",
		],
		"instructions_text_eng": [
			"Great!",
			"Now, the most important to become invisible - is to bend down and move quieter.",
			"To do that, press left control button (or other if you set it),",
			"When you are in that position, the detection indicator appears on your screen.",
			"If you're moving in front of enemy's face without bending down, they will notice you right away.",
			"Try to avoid the light.",
			"Even if you move crouched, you will be quickly noticed, if there is ightbulb nearby.",
			"But even if you are noticed by one or two enemies - don't worry,",
			"because you can eliminate them before alarm begins.",
			"If more than three enemies notice you, your stealth is officially failed.",
			"Try to use silenced weapons,",
			"because loud guns - failed stealth guarantee!"
		],
		"instructions_timers": [
			0.9,
			3.8,
			2.7,
			4.3,
			6.2,
			1.5,
			5.0,
			3.8,
			2.8,
			6.0,
			2.1,
			2.9,
		],
		
		"try": preload("res://assets/audio/phrases/instructions/stealth/stealth-try.ogg"),
		"try_text": [
			"Если хотите попрактиковаться,",
			"возьмите пистолет с глушителем и попробуйте скрытно устранить все камеры,",
			"которые находятся позади меня"
		],
		"try_text_eng": [
			"If you want to practice,",
			"take that silenced pistol and try to stealthy eliminate all cameras,",
			"that are located behind me."
		],
		"try_timers": [
			1.2,
			3.4,
			1.7
		],
		
		"pistol": preload("res://assets/audio/phrases/instructions/stealth/stealth-pistol.ogg"),
		"pistol_text": [
			"Ваш пистолет находится в кобуре на боку",
			"Чтобы достать его, повернитесь направо и нажмите кнопку после появления подсказки",
			"Кобура была добавлена в игру ради вашего удобства, поскольку пистолет обладает собственной физикой",
			"Это было сделано для того чтобы моделька не залезала за текстуры",
			"Имейте это ввиду ;)"
		],
		"pistol_text_eng": [
			"Your pistol is in its holster on your hip.",
			"To get it, turn camera right and press button after hint appears.",
			"Holster was added in the game for your convenience, because pistol has his own physics.",
			"This was done so that the model did not get through the textures.",
			"Keep this in mind ;)"
		],
		"pistol_timers": [
			2.4,
			3.6,
			5.0,
			3.6,
			1.3
		],
		
		"succeed": preload("res://assets/audio/phrases/instructions/stealth/stealth-succeed.ogg"),
		"succeed_text": ["Поздравляю, из вас вышел бы отличный Солид Снейк!"],
		"succeed_text_eng": ["Congratulations! You'll make a great Solid Snake!"],
		"succeed_timers": [3.1],
		
		
		"noticed": preload("res://assets/audio/phrases/instructions/stealth/stealth-noticed.ogg"),
		"noticed_text": ["О, нет! Вас заметили! Попробуйте еще раз."],
		"noticed_text_eng": ["Oh, no! You have been noticed! Try again."],
		"noticed_timers": [3.7],
		
		"die": preload("res://assets/audio/phrases/instructions/stealth/stealth-revolt.ogg"),
		"die_text": ["Ауч, это было больно..."],
		"die_text_eng": ["Ouch, this was hurt..."],
		"die_timers": [1.6]
	}


func _on_passArea_body_exited(body):
	playerExit(body)


func _on_passArea_body_entered(body):
	if !is_training:
		playerEnter(body)


func _process(delta):
	if timer > 0:
		timer -= delta


func _input(event):
	checkingNod(event)


func _sayAboutPistol():
	pistol_phrase_told = true
	mrHandy.stopTalking()
	yield(get_tree().create_timer(0.1),"timeout")
	_changePhrase("pistol")
	yield(mrHandy,"finished")
	_changePhrase("greetings", false)


func decreseRoboEyesCount(scores:int):
	if !is_training:
		if G.english:
			messages.ShowMessage("doesn't count without a pistol :p", 1)
		else:
			messages.ShowMessage("без пистолета не считается :p", 1)
		return
	
	got_scores += scores
	G.scores += scores
	if G.english:
		messages.ShowMessage("Got " + str(scores) + " scores", 1)
	else:
		messages.ShowMessage(str(scores) + " очков получено", 1)
	
	if roboEyes_count > 1:
		roboEyes_count -= 1
	else:
		pistol.getWeapon()
		
		if mrHandy.Health > 0:
			_changePhrase("succeed", false)
			last_phrase = true
			yield(get_tree().create_timer(0.1),"timeout")
			yield(mrHandy,"finished")
			_changePhrase("greetings", false)
			last_phrase = false


func startTraining():
	if applejack_training.is_training:
		applejack_training.rifle.getWeapon()
	
	is_training = true
	mrHandy.stopTalking()
	playerHere = false
	checkNod = false
	_resetTimers()
	yield(get_tree().create_timer(0.1),"timeout")

	if !pistol_phrase_told:
		_sayAboutPistol()
	
	if got_scores > 0:
		if G.english:
			messages.ShowMessage("Reset " + str(got_scores) + " scores", 1.5)
		else:
			messages.ShowMessage(str(got_scores) + " очков сброшено", 1.5)
		G.decreaseScores(got_scores)
		got_scores = 0
		eqipManager.removeReservedEqip()
	
	roboEyes_count = 5
	var roboEyes = get_node("/root/Main/roboEyes").get_children()
	for roboEye in roboEyes:
		roboEye.Reset()
		roboEye.visible = true
		roboEye.active = true



func loseTraining():
	$audi.play()
	pistol.getWeapon(false)
	is_training = false
	var roboEyes = get_node("/root/Main/roboEyes").get_children()
	for roboEye in roboEyes:
		roboEye.active = false
	
	if mrHandy.Health > 0:
		_changePhrase("noticed", false)
		last_phrase = true
		yield(get_tree().create_timer(0.1),"timeout")
		yield(mrHandy, "finished")
		_changePhrase("greetings", false)
		last_phrase = false


func finishTraining():
	is_training = false
	var roboEyes = get_node("/root/Main/roboEyes").get_children()
	for roboEye in roboEyes:
		roboEye.visible = false
		roboEye.active = false

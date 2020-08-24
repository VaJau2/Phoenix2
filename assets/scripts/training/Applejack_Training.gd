extends "TrainingBase.gd"

onready var pinkie_training = get_node("../../stealth/passArea")
onready var messages = get_node("/root/Main/canvas/messages")
onready var eqipManager = get_node("../../equipment")
onready var rifle = get_node("../table/rifle")
var targets_count = 5
var targets

var got_scores = 0



func _ready():
	targets = get_node("../targets").get_children()
	mrHandy = get_node("../MrHandy-Applejack")
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/combat/combat-greetings.ogg"),
		"greetings_text": [
			"Приветствую солдат",
			"Если вы хотите прослушать инструкции о ведении боя, кивните один раз"
		],
		"greetings_timers": [1.5, 3.9],
		
		
		"instructions": preload("res://assets/audio/phrases/instructions/combat/combat-instructions.ogg"),
		"instructions_text": [
			"Итак",
			"Для успешного ведения боя с противником",
			"наносите ему как можно больше урона и старайтесь избегать ответного урона",
			"В вашей миссии вам с наибольшей вероятностью встретятся такие противники, как зебры",
			"Зебры - мастера ближнего боя",
			"Не вступайте в ближний бой с любым из них, вас скорее всего убьют",
			"Старайтесь держать дистанцию от них и стрелять как можно точнее",
			"и залог победы гарантирован",
			"Также, судя по нашим разведданным, вражескую базу охраняют снайперы",
			"Снайперы зебр имеют широкий и дальний обзор",
			"но всегда направлены только в одну сторону из-за неповоротливости своих винтовок",
			"Чтобы устранить снайпера",
			"нужно стараться не попадать в поле его обзора и подойти к нему как можно ближе",
			"Обычно хватает одного выстрела"
		],
		"instructions_timers": [
			0.6,
			2.2,
			4.8,
			4.2,
			2.0,
			4.8,
			3.4,
			1.6,
			5.8,
			2.7,
			3.9,
			1.7,
			3.4,
			1.7
		],
		
		"try": preload("res://assets/audio/phrases/instructions/combat/combat-try.ogg"),
		"try_text": [
			"Если вы хотите попрактиковаться в стрельбе,",
			"берите эту винтовку и стреляйте по мишеням"
		],
		"try_timers": [
			2.5,
			2.4
		],
		
		"succeed": preload("res://assets/audio/phrases/instructions/combat/combat-succeed.ogg"),
		"succeed_text": ["Отлично, вы поразили все мишени!"],
		"succeed_timers": [3],
		
		"die": preload("res://assets/audio/phrases/instructions/combat/combat-revolt.ogg"),
		"die_text": ["Не стреляй в своих, солдат!"],
		"die_timers": [2.7]
	}


func _on_passArea_body_exited(body):
	playerExit(body)


func _on_passArea_body_entered(body):
	playerEnter(body)


func _process(delta):
	if timer > 0:
		timer -= delta


func _input(event):
	checkingNod(event)


func startTraining():
	if pinkie_training.is_training:
		pinkie_training.pistol.getWeapon()
	
	is_training = true
	if got_scores > 0:
		messages.ShowMessage(str(got_scores) + " очков сброшено", 1.5)
		G.scores -= got_scores
		got_scores = 0
		eqipManager.removeReservedEqip()
	
	targets_count = 5
	for target in targets:
		target.dropScores(self)


func hitTarget(scores: int):
	got_scores += scores
	G.scores += scores
	messages.ShowMessage(str(scores) + " очков получено", 1)
	
	if targets_count > 1:
		targets_count -= 1
	else:
		rifle.getWeapon()
		if mrHandy.Health > 0:
			_changePhrase("succeed")
			yield(mrHandy,"finished")
			yield(get_tree().create_timer(0.1),"timeout")
			_changePhrase("greetings", false)


func finishTraining():
	is_training = false
	var rotate_delta = 0
	while rotate_delta < 95:
		rotate_delta += 5
		for target in targets:
			if target.rotation_degrees.x > -90:
				target.rotation_degrees.x -= 5
			else:
				target.active = false
		yield(get_tree(),"idle_frame")

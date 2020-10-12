extends "TrainingBase.gd"

onready var pinkie_training = get_node("../../stealth/passArea")
onready var messages = get_node("/root/Main/canvas/messages")
onready var eqipManager = get_node("../../equipment")
onready var rifle = get_node("../table/rifle")
var targets_count = 5
var targets

var got_scores = 0

var lang = 0
var hints = {
	"shoot": ["ЛКМ - выстрелить", "LMB - to shoot"],
	"close": ["ПКМ - приблизить", "RMB - to close view"]
}



func _ready():
	if G.english: 
		lang = 1
	targets = get_node("../targets").get_children()
	mrHandy = get_node("../MrHandy-Applejack")
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/combat/combat-greetings.ogg"),
		"greetings_text": [
			"Приветствую солдат!",
			"Если вы хотите прослушать инструкции о ведении боя, кивните один раз"
		],
		"greetings_text_eng": [
			"Greetings, soldier!",
			"If you wish to listen my combat instructions, nod one time."
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
		"instructions_text_eng": [
			"So",
			"For successful combat with enemy,",
			"try to inflict as much damage as possible and to avoid retaliation.",
			"In your mission with high probability you will meet opponents like zebras.",
			"Zebras are melee masters.",
			"Don't try to engage in close combat with any of them, you will probably be eliminated.",
			"Try to keep distance from them and shoot as accurate as possible,",
			"and you will win.",
			"Also judging by our intelligence, enemy's base is guarded by snipers.",
			"Zebra snipers have wide and long view,",
			"but directed only in one direction because of the slowness of their rifles.",
			"To eliminate a sniper,",
			"you need to keep away from their view and get as close as possible.",
			"Usually one shot is enough."
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
		"try_text_eng": [
			"If you want to practice in shooting,",
			"take this rifle and hit the targets."
		],
		"try_timers": [
			2.5,
			2.4
		],
		
		"succeed": preload("res://assets/audio/phrases/instructions/combat/combat-succeed.ogg"),
		"succeed_text": ["Отлично, вы поразили все мишени!"],
		"succeed_text_eng": ["Great, you hitted all the targets!"],
		"succeed_timers": [3],
		
		"die": preload("res://assets/audio/phrases/instructions/combat/combat-revolt.ogg"),
		"die_text": ["Не стреляй в своих, солдат!"],
		"die_text_eng": ["Don't shoot to allies, soldier!"],
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
	
	targets_count = 5
	for target in targets:
		target.dropScores(self)
	
	if got_scores > 0:
		if G.english:
			messages.ShowMessage("reset " + str(got_scores) + " scores ", 1.5)
		else:
			messages.ShowMessage(str(got_scores) + " очков сброшено", 1.5)
		G.decreaseScores(got_scores)
		got_scores = 0
		eqipManager.removeReservedEqip()
	else:
		yield(get_tree().create_timer(1),"timeout")
		messages.ShowMessage(hints["shoot"][lang])
		yield(get_tree().create_timer(4),"timeout")
		messages.ShowMessage(hints["close"][lang])
		yield(get_tree().create_timer(5),"timeout")


func hitTarget(scores: int):
	got_scores += scores
	G.scores += scores
	if G.english:
		messages.ShowMessage("got " + str(got_scores) + " scores ", 1.5)
	else:
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

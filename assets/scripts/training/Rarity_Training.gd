extends "TrainingBase.gd"

onready var messages = get_node("/root/Main/canvas/messages")
onready var eqipManager = get_node("../../equipment")
const PASS_SCORES = 24
const GUN_DAMAGE = 5

var player_starting_teleport = false
var start_timer_teleport = 1.5


var ringFly1 = preload("res://assets/audio/flying/flyingRing1.wav")
var ringFly2 = preload("res://assets/audio/flying/flyingRing2.wav")
var failSound = preload("res://assets/audio/futniture/stealth_fail.wav")
onready var startMarker = get_node("../markers/marker1")

var increase = 1
var got_scores_teleport = 0
var got_scores_shield = 0

onready var machineGun = get_node("../wall-gun")
var player_starting_shield = false
var start_timer_shield = 1.5
var shooting = false


func _ready():
	mrHandy = get_node("../MrHandy-Rarity")
	
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/magic/magic-greetings.ogg"),
		"greetings_text": [
			"Доброго дня вам.",
			"Здесь вы можете проверить соответствие своих магических способностей требованиям предстоящей миссии.",
			"Также вы можете прослушать мои инструкции,",
			"для этого вам нужно кивнуть один раз."
		],
		"greetings_text_eng": [
			"Good day to you.",
			"Here you can check matching your magical abilities to the requirements of the upcoming mission.",
			"Also you can listen to my instructions,",
			"to do this you need to nod one time."
		],
		"greetings_timers": [1.3, 4.5, 2.5, 2.1],
		
		
		"not_unicorn": preload("res://assets/audio/phrases/instructions/magic/magic-non-unicorns.ogg"),
		"not_unicorn_text": ["Прошу прощения, эти инструкции предназначены только для единорогов"],
		"not_unicorn_text_eng": ["My apologies, this instructions are only for unicorns."],
		"not_unicorn_timers": [3.5],
		
		
		"instructions": preload("res://assets/audio/phrases/instructions/magic/instructions.ogg"),
		"instructions_text": [
			"Обычно для единорогов не проблема использовать магию, так как это наша врожденная способность",
			"Даже во время боя сфокусироваться и сотворить какое-либо боевое заклинание, которым ты был обучен до этого, не составляет труда",
			"Однако, ваша миссия будет проходить во время ночи,",
			"и важной необходимостью является незаметность.",
			"Использование телекинеза крайне нерекомендованно, поскольку телекинетическое облако сильно привлекает внимание.",
			"Поэтому оружие вы должны носить способом земных пони.",
			"Приемлимыми в данном случае является заклинания телепортации и магического щита",
			"Однако, даже они могут привлечь внимание.",
			"Постарайтесь использовать их как можно реже.",
		],
		"instructions_text_eng": [
			"Usually it's not a problem for unicorns to use magic, as it is our natural ability.",
			"Even during the fight it's not hard to focus and make some combat spell, which you were trained to do before.",
			"However, your mission takes place during the night,",
			"and important necessity is invisibility.",
			"Using telekinesis is highly inappropriate, inasmuch telekinetic cloud strongly attracts attention.",
			"That's why you need to use weapons in earth pony style.",
			"In this case, teleportation and magic shield spells are acceptable.",
			"However, even this spells may attract attention.",
			"Try to use them as seldom as possible."
		],
		"instructions_timers": [
			4.6,
			5.6,
			3.0,
			2.7,
			6.7,
			3.6,
			4.7,
			3.0,
			2.6
		],
		
		"try": preload("res://assets/audio/phrases/instructions/magic/instructions-try.ogg"),
		"try_text": [
			"Для проверки способностей создания магического щита, подойдите в обозначенную область слева и дождитесь сигнала",
			"Для проверки способностей телепортации, подойдите в область справа,",
			"дождитесь сигнала и телепортируйтесь в обозначенные места."
		],
		"try_text_eng": [
			"To check your abilities of creating magic shield, go to the designated area on the left and wait for the signal.",
			"To check your abilities of teleportation, go to the area on the right,",
			"wait for the signal and teleport on marked areas."
		],
		"try_timers": [
			6.5,
			4.5,
			2.8
		]
	}


func _on_passArea_body_exited(body):
	playerExit(body)


func _on_passArea_body_entered(body):
	if !is_training:
		playerEnter(body, 1, "not_unicorn")


func _on_startAreaTeleport_body_entered(body):
	if body.name == "Player" && G.race == 1:
		player_starting_teleport = true


func _on_startAreaTeleport_body_exited(body):
	if body.name == "Player" && G.race == 1:
		player_starting_teleport = false
		start_timer_teleport = 1.5


func _on_startAreaShield_body_entered(body):
	if body.name == "Player" && G.race == 1:
		player_starting_shield = true


func _on_startAreaShield_body_exited(body):
	if body.name == "Player" && G.race == 1:
		shooting = false
		player_starting_shield = false
		start_timer_shield = 1.5


func startTrainingTeleport():
	is_training = true
	startMarker.start()
	
	mrHandy.stopTalking()
	playerHere = false
	checkNod = false
	_resetTimers()
	
	G.player.audi_hitted.stream = failSound
	G.player.audi_hitted.play()
	if got_scores_teleport > 0:
		if G.english:
			messages.ShowMessage("Reset:" + str(got_scores_teleport) + " scores", 1.5)
		else:
			messages.ShowMessage(str(got_scores_teleport) + " очков сброшено", 1.5)
		G.scores -= got_scores_teleport
		got_scores_teleport = 0
		eqipManager.removeReservedEqip()
	increase = 1


func finishTraining():
	is_training = false
	got_scores_teleport = int(increase * PASS_SCORES)
	G.scores += got_scores_teleport
	if G.english:
		messages.ShowMessage("Got:" + str(got_scores_teleport) + " scores", 1.5)
	else:
		messages.ShowMessage(str(got_scores_teleport) + " очков получено", 1)
	G.player.audi_hitted.stream = ringFly2
	G.player.audi_hitted.play()


func loseTraining():
	is_training = false
	G.player.audi_hitted.stream = failSound
	G.player.audi_hitted.play()



func startTrainingShield():
	if got_scores_shield > 0:
		if G.english:
			messages.ShowMessage("Reset:" + str(got_scores_shield) + " scores", 1.5)
		else:
			messages.ShowMessage(str(got_scores_shield) + " очков сброшено", 1.5)
		G.scores -= got_scores_shield
		got_scores_shield = 0
		eqipManager.removeReservedEqip()
		G.player.stats.Health = 100
	
	mrHandy.stopTalking()
	playerHere = false
	checkNod = false
	_resetTimers()
	
	shooting = true
	G.player.audi_hitted.stream = failSound
	G.player.audi_hitted.play()
	yield(get_tree().create_timer(0.5),"timeout")
	
	while(shooting):
		if G.player.stats.mana > G.player.stats.SHIELD_COST:
			machineGun.get_node("anim").play("shoot")
			machineGun.get_node("audi").play()
			
			if G.player.stats.shieldMesh.visible:
				G.player.stats.TakeDamage(1, Vector3.ZERO)
				G.player.stats.mana -= GUN_DAMAGE
				got_scores_shield += GUN_DAMAGE - 1
				G.scores += GUN_DAMAGE
				if G.english:
					messages.ShowMessage("Got:" + str(GUN_DAMAGE) + " scores", 1.5)
				else:
					messages.ShowMessage(str(GUN_DAMAGE) + " очков получено", 1)
				
				G.player.audi_hitted.stream = ringFly1
				G.player.audi_hitted.play()
			else:
				G.player.stats.TakeDamage(GUN_DAMAGE, Vector3.ZERO)
				G.player.audi_hitted.stream = failSound
				G.player.audi_hitted.play()
				shooting = false
		else:
			G.player.audi_hitted.stream = ringFly2
			G.player.audi_hitted.play()
			shooting = false
		yield(get_tree().create_timer(1),"timeout")


func _process(delta):
	if timer > 0:
		timer -= delta
	
	if !is_training && player_starting_teleport:
		if start_timer_teleport > 0:
			start_timer_teleport -= delta
		else:
			start_timer_teleport = 1.5
			player_starting_teleport = false
			playerExit(G.player)
			startTrainingTeleport()
	
	if player_starting_shield:
		if start_timer_shield > 0:
			start_timer_shield -= delta
		else:
			start_timer_shield = 1.5
			player_starting_shield = false
			startTrainingShield()


func _input(event):
	checkingNod(event)

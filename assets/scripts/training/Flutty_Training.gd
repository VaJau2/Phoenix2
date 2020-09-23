extends "TrainingBase.gd"

onready var messages = get_node("/root/Main/canvas/messages")
const SCORES = 300
var scores_onetime = true


func _ready():
	mrHandy = get_node("../MrHandy-Fluttershy")
	phrases = {
		"greetings": preload("res://assets/audio/phrases/instructions/extra/extra-greetings.ogg"),
		"greetings_text": [
			"Привет. Хочешь дополнительных очков, просто за то, что ты такая хорошая?"
		],
		"greetings_text_eng": [
			"Hi there. Want some extra score points, just because you are so nice?"
		],
		"greetings_timers": [4],
		
		
		"greetings2": preload("res://assets/audio/phrases/instructions/extra/extra-greetings2.ogg"),
		"greetings2_text": [
			"О, привет...",
			"Кажется, ты не земная пони...",
			"Как ты сюда попала?..",
			"Эм...",
			"Это будет немножко не честно по отношению к земным пони...",
			"...Но...",
			"Хочешь дополнительных очков?",
		],
		"greetings2_text_eng": [
			"Oh, hi...",
			"Seems like you are not earthpony...",
			"How did you get here?..",
			"Em...",
			"This will be a little unfair to earthponies...",
			"...But...",
			"Want some extra points?",
		],
		"greetings2_timers": [1.3, 2, 1.8, 1.4, 3.2, 1, 1.8],
		
		"anyway": preload("res://assets/audio/phrases/instructions/extra/extra-anyway.ogg"),
		"anyway_text": [
			"А я все равно дам тебе эти очки, ведь ты действительно хорошая!",
			"Удачи!"
		],
		"anyway_text_eng": [
			"I'll give this points to you anyway, because you are really nice!",
			"Good luck!"
		],
		"anyway_timers": [3.2, 1],
		
		"no": preload("res://assets/audio/phrases/instructions/extra/extra-no.ogg"),
		"no_text": [
			"Нет?.. ",
			"Ох, ты такая честная...",
			"Жалко, что они не узнают, насколько ты хорошая...",
			"Но я знаю.",
			"Ты действительно милашка.",
		],
		"no_text_eng": [
			"No?..",
			"Oh, you are so honest ...",
			"Wish they knew how good you are ...",
			"But I know.",
			"You are really cute.",
		],
		"no_timers": [1.1, 1.7, 2.2, 1.5, 1.7],
		
		"morepoints": preload("res://assets/audio/phrases/instructions/extra/extra-morepoints.ogg"),
		"morepoints_text": [
			"Ути какая маленькая миленькая земная поняшка, которой не досталось лишнего испытания для фарма очков на снаряжение!",
			"Что за бедное маленькое создание, обделенное возможностью летать и телепортироваться!",
			"Тебя абсолютно нечему научить, ведь геймплей за тебя прост и понятен!",
			"Но кто сказал, что это плохо? Вы, земные поняхи, можете выбивать двери и бегать!",
			"Да, не очень богато, по сравнению с полетом или телепортацией, но как насчет дополнительных 50ХП?",
			"Земные поняхи также важны, как и остальные расы, и ты обязательно это докажешь!",
			"Держи дополнительные очки, милашка.",
		],
		"morepoints_text_eng": [
			"Aww, look at this little cute earthpony, who didn't get extra test to farming score points for equipment!",
			"What a poor little creature, who is deprived of the ability to fly or teleport!",
			"You have absolutely nothing to teach, because your gameplay is simple and clear!",
			"But who said that this is bad? You, earthponies, are able to smash doors and even run!",
			"Yes, it's not much in comparison of flying and teleportation, but what about exptra 50 health points?",
			"Earthponies are just as important as other races, and you definitely proove that!",
			"Here your extra points, cutie.",
		],
		"morepoints_timers": [5.6, 5, 4.4, 5.6, 6.4, 4.5, 2.1],
		
		"morepoints2": preload("res://assets/audio/phrases/instructions/extra/extra-morepoints2.ogg"),
		"morepoints2_text": [
			"Тебе, возможно, пришлось потрудиться, чтобы попасть сюда, поэтому ладно. Держи...",
		],
		"morepoints2_text_eng": [
			"You probably had to work hard to get here, so okay. Here you go...",
		],
		"morepoints2_timers": [4.1],
		
		"die": preload("res://assets/audio/phrases/instructions/extra/extra-revolt.ogg"),
		"die_text": [" Ты все равно хорошая, я верю в это..."],
		"die_text_eng": ["You're still nice, I believe it..."],
		"die_timers": [3]
	}
	
	if G.race != 0:
		_changePhrase("greetings2", false)

func _givePoints():
	scores_onetime = false
	G.scores += SCORES
	if G.english:
			messages.ShowMessage("Got:" + str(SCORES) + " scores", 1.5)
	else:
		messages.ShowMessage(str(SCORES) + " очков получено", 1.5)


func _on_passArea_body_entered(body):
	if scores_onetime:
		playerEnter(body)


func _on_passArea_body_exited(body):
	playerExit(body)


func _input(event):
	if scores_onetime:
		if checkNod:
			if mrHandy.Health <= 0:
				checkNod = false
				scores_onetime = false
				return
			
			if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				if event.relative.x > 25: #просчитываем отрицательное качание головой
					if notLeftTimer > 0:
						notLeftTimer -= 0.1
				elif event.relative.x < -25:
					if notRightTimer > 0:
						notRightTimer -= 0.1
					else:
						_resetTimers()
						checkNod = false
						if G.race == 0:
							_changePhrase("anyway")
							yield(mrHandy,"finished")
							yield(get_tree().create_timer(0.1),"timeout")
							_givePoints()
						else:
							_changePhrase("no")
				
				
				if event.relative.y > 30:  #просчитываем положительное качание головой
					if nodUpTimer > 0:
						nodUpTimer -= 0.1
				elif event.relative.y < -30:
					if nodUpTimer <= 0:
						if nodDownTimer > 0:
							nodDownTimer -= 0.1
						else:
							_resetTimers()
							checkNod = false
							if G.race == 0:
								_changePhrase("morepoints")
							else:
								_changePhrase("morepoints2")
							yield(mrHandy,"finished")
							yield(get_tree().create_timer(0.1),"timeout")
							_givePoints()

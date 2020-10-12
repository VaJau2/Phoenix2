extends Area

var phrases = {}
var mrHandy = null

var is_training = false
var last_phrase = false #нужно, чтоб не начиналась проверка на покачивания головой
var playerHere = false
var checkNod = false
var timer = 0

var nodUpTimer = 0.3
var nodDownTimer = 0.3
var notLeftTimer = 0.3
var notRightTimer = 0.3

static func _getKey(action):
	var actions = InputMap.get_action_list(action)
	return OS.get_scancode_string(actions[0].get_scancode())


func _resetTimers():
	nodUpTimer = 0.3
	nodDownTimer = 0.3
	notLeftTimer = 0.3
	notRightTimer = 0.3


func _changePhrase(phrase_name, talk=true):
	mrHandy.phrase = phrases[phrase_name]
	mrHandy.phraseText = phrases[phrase_name + "_text"]
	mrHandy.phraseTextEng = phrases[phrase_name + "_text_eng"]
	mrHandy.textTimers = phrases[phrase_name + "_timers"]
	mrHandy.textI = 0
	if talk:
		mrHandy.talkToPlayer()


func playerExit(body, temp_timer=0.6):
	if body.name == "Player":
		yield(get_tree().create_timer(temp_timer),"timeout")
		mrHandy.stopTalking()
		playerHere = false
		checkNod = false
		_resetTimers()


func playerEnter(body, race=null, not_race=null):
	if body.name == "Player" && timer <= 0 && mrHandy.Health > 0:
		yield(get_tree().create_timer(0.5),"timeout")
		if race != null && G.race != race:
			_changePhrase(not_race)
		else:
			playerHere = true
			mrHandy.textI = 0
			mrHandy.talkToPlayer()
			if !last_phrase:
				yield(mrHandy,"finished")
				if playerHere:
					checkNod = true
			else:
				last_phrase = false
		timer = 5


func checkingNod(event):
	if checkNod:
		if mrHandy.Health <= 0:
			checkNod = false
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
					_changePhrase("try")
					yield(mrHandy,"finished")
					yield(get_tree().create_timer(0.1),"timeout")
					_changePhrase("greetings", false)
			
			
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
						_changePhrase("instructions")
						yield(mrHandy,"finished")
						yield(get_tree().create_timer(0.4),"timeout")
						if mrHandy.Health > 0:
							_changePhrase("try")
							yield(mrHandy,"finished")
							yield(get_tree().create_timer(0.1),"timeout")
							_changePhrase("greetings", false)

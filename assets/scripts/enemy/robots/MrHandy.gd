extends Enemy

onready var subs = get_node("/root/Main/canvas/subtitles")

onready var animTree = get_node("animTree")
var playback

onready var break_audi = get_node("audi-break")
var break2_sound = preload("res://assets/audio/guns/result/mrHandy_break-2.wav")

export var phrase: AudioStream
export var phraseText = []
export var textTimers = []
var textI = 0

export var animsCount = 2

var temp_delta = 0.1

signal finished

func stopTalking():
	if textI < phraseText.size():
		textI = phraseText.size()
		audi.stop()
		subs.visible = false
		yield(get_tree(),"idle_frame")
		textI = 0
		emit_signal("finished")


func talkToPlayer():
	if Health > 0:
		if textI >= phraseText.size():
			return
		var talkI = randi() % animsCount + 1
		playback.travel("Talk" + str(talkI))
		audi.stop()
		yield(get_tree(),"idle_frame")
		audi.stream = phrase
		audi.play()
		subs.visible = true
		
		var tempTimers = []
		for timer in textTimers:
			tempTimers.append(timer)
		
		while(textI < phraseText.size()):
			if G.paused:
				yield(get_tree(), "idle_frame")
			else:
				lookAtPlayer()
				
				if randf() > 0.65:
					talkI = randi() % 2 + 1
					playback.travel("Talk" + str(talkI))
				subs.text = phraseText[textI]
				if tempTimers[textI] > 0:
					tempTimers[textI] -= temp_delta
					yield(get_tree(), "idle_frame")
				else:
					textI += 1
		subs.visible = false
	emit_signal("finished")


func lookAtPlayer():
	if Health > 0:
		var player_pos = G.player.global_transform.origin
		player_pos.y = global_transform.origin.y
		look_at(player_pos, Vector3.UP)


func TakeDamage(damage: int, shapeID = 0):
	stopTalking()
	yield(get_tree(),"idle_frame")
	
	if Health > 1:
		break_audi.play()
		Health = 1
		var my_script = get_node("../passArea")
		if my_script && "phrases" in my_script && "die" in my_script.phrases:
			var temp_phrase = phrase
			var temp_text = phraseText
			var temp_timers = textTimers
			
			phrase = my_script.phrases.die
			phraseText = my_script.phrases.die_text
			textTimers = my_script.phrases.die_timers
			textI = 0
			
			talkToPlayer()
			yield(self,"finished")
			stopTalking()
			yield(get_tree().create_timer(0.1),"timeout")
			
			phrase = temp_phrase
			phraseText = temp_text
			textTimers = temp_timers
	else:
		break_audi.stream = break2_sound
		break_audi.play()
		Health = 0
		var fire = get_node("Armature/Skeleton/BoneAttachment/fire")
		if fire:
			fire.queue_free()
		playback.travel("Die")
		set_collision_layer(0)
		set_collision_mask(0)
		var pos_y = 0.5
		while pos_y > 0:
			pos_y -= 0.1
			translation.y -= 0.1
			yield(get_tree(),"idle_frame")


func _ready():
	playback = animTree.get("parameters/playback")
	playback.start("Idle")


func _process(delta):
	if Health > 0:
		temp_delta = delta

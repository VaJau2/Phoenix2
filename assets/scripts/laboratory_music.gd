extends Node

const SPEED = 20
const SPEED_FIGHT = 30
const COOLDOWN = 3
const FIGHT_COOLDOWN = 30
const DEALTH_COOLDOWN = 6

onready var audi1 = get_node("non_fight")
onready var audi2 = get_node("fight")

var non_fight_begin = preload("res://assets/audio/music/laboratory/non_fight_begin.ogg")
var non_fight = preload("res://assets/audio/music/laboratory/non_fight.ogg")
var fight = preload("res://assets/audio/music/laboratory/fight.ogg")

var fight_music_on = false
var non_fight_music_on = true
var music_muted = false

var cooldown_timer = 0

func _muteMusic(mute, delta):
	if mute:
		if non_fight_music_on:
			audi1.volume_db = G.player._setValueZero(audi1.volume_db, SPEED, -20, delta)
			if audi1.volume_db == -20:
				music_muted = true
				cooldown_timer = DEALTH_COOLDOWN
		elif fight_music_on:
			audi2.volume_db = G.player._setValueZero(audi2.volume_db, SPEED, -20, delta)
			if audi2.volume_db == -20:
				music_muted = true
				cooldown_timer = DEALTH_COOLDOWN
		
		else:
			audi1.volume_db = G.player._setValueZero(audi1.volume_db, SPEED, -20, delta)
			audi2.volume_db = G.player._setValueZero(audi2.volume_db, SPEED, -20, delta)
			
			if audi1.volume_db == -20 && audi2.volume_db == -20:
				music_muted = true
				cooldown_timer = DEALTH_COOLDOWN
	else:
		if non_fight_music_on:
			audi1.volume_db = G.player._setValueZero(audi1.volume_db, SPEED, 0, delta)
			if audi1.volume_db == 0:
				music_muted = false
		elif fight_music_on:
			audi2.volume_db = G.player._setValueZero(audi2.volume_db, SPEED, 0, delta)
			if audi2.volume_db == 0:
				music_muted = false
		else:
			music_muted = false


func _ready():
	yield(get_tree().create_timer(10),"timeout")
	audi1.stream = non_fight_begin
	audi1.play()
	yield(audi1,"finished")
	audi1.stream = non_fight
	audi1.play()
	audi2.stream = fight
	audi2.play()


func _process(delta):
	if G.player.stats.black_screen.visible:
		if !music_muted:
			_muteMusic(true, delta)
			return
	else:
		if music_muted:
			if cooldown_timer > 0:
				cooldown_timer -= delta
			else:
				_muteMusic(false, delta)
			
			return
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
	else:
		if G.player.stealth.stage != 2: #non_fight_music
			if !non_fight_music_on:
				fight_music_on = false
				
				if audi1.volume_db < 0:
					audi1.volume_db += delta * SPEED
				else:
					audi1.volume_db = 0
				
				if audi2.volume_db > -20:
					audi2.volume_db -= delta * SPEED
				else:
					audi2.volume_db = -20
				
				if audi1.volume_db == 0 && audi2.volume_db == -20:
					non_fight_music_on = true
					cooldown_timer = COOLDOWN
		
		else:   #fight_music
			if !fight_music_on:
				non_fight_music_on = false
				
				if audi2.volume_db < 0:
					audi2.volume_db += delta * SPEED_FIGHT
				else:
					audi2.volume_db = 0
				
				if audi1.volume_db > -20:
					audi1.volume_db -= delta * SPEED_FIGHT
				else:
					audi1.volume_db = -20
				
				if audi2.volume_db == 0 && audi1.volume_db == -20:
					fight_music_on = true
					cooldown_timer = FIGHT_COOLDOWN

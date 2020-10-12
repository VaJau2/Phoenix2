extends Spatial

const ALARM_TIME = 200
const ALARM_ENEMIES_COUNT = 3
const ALARM_FAR_DIST = 60
const ALARM_CLOSE_DIST = 20
const SPAWN_COOLDOWN = 4

const MAX_DEAD = 6
const MAX_ALIVE = 12

var dead_array = []

var alarmed = false
var alarm_timer = 0
var attacking_count = 0
var enemies_count = 13
var spawners = []
var spawn_cooldown_timer = 0

onready var music = get_node("../Player/music")
export var fightMusic: AudioStream
export var dragonMusic: AudioStream
var music_volume = -3
var onetime_stop = false
var music_stopping = true


func addDead(new_dead):
	dead_array.append(new_dead)
	if dead_array.size() > MAX_DEAD:
		var player_pos = G.player.global_transform.origin
		var max_dist = 0
		var farDead = dead_array[0]
		
		for temp_dead in dead_array:
			var wr = weakref(temp_dead)
			if !(wr.get_ref()):
				return
			var dead_pos = temp_dead.global_transform.origin
			var temp_dist = player_pos.distance_to(dead_pos)
			if temp_dist > max_dist:
				max_dist = temp_dist
				farDead = temp_dead
		
		dead_array.erase(farDead)
		farDead.queue_free()


func startAlarm():
	if !alarmed:
		onetime_stop = false
		alarm_timer = ALARM_TIME
		music.stream = fightMusic
		music.play()
		alarmed = true
		while(music_volume < 0):
			music_volume += 0.02
			music.set_volume_db(music_volume)
			yield(get_tree(),"idle_frame")


func stopAlarm():
	onetime_stop = true
	while(music_volume > -3):
		music_volume -= 0.05
		music.set_volume_db(music_volume)
		yield(get_tree(),"idle_frame")
	music.stop()


func activateDragon():
	if alarm_timer == 0:
		var scores = get_node("../canvas/ResultMenu")
		scores.score_reasons.Silent_Assasin += 1
	
	yield(get_tree().create_timer(1.5),"timeout")
	var dragon = $dragon
	dragon.get_node("audi-wings").play()
	dragon.visible = true
	dragon.active = true
	G.player.stealth.addAttackEnemy(dragon)
	stopAlarm()
	while music_volume > -3:
		music_volume -= 0.05
		yield(get_tree(),"idle_frame")
	yield(get_tree().create_timer(1),"timeout")
	playDragonMusic()


func playDragonMusic():
	alarmed = true
	music.stream = dragonMusic
	music.play()
	while(music_volume < 0):
		music_volume += 0.02
		music.set_volume_db(music_volume)
		yield(get_tree(),"idle_frame")


func _spawnEnemy():
	for spawner in spawners:
		if !spawner.playerSee:
			var spawnerPos = Vector2(spawner.global_transform.origin.x, spawner.global_transform.origin.z)
			var playerPos = Vector2(G.player.global_transform.origin.x, G.player.global_transform.origin.z)
			
			var tempDist = spawnerPos.distance_to(playerPos)
			if tempDist > ALARM_CLOSE_DIST && tempDist < ALARM_FAR_DIST:
				spawner.spawn()
				spawners.erase(spawner)
				enemies_count += 1
				return true
	return false


func _getCloserZebra():
	for zebra in get_children():
		if zebra.name != "spawners" && zebra.name != "dragon" && zebra.Health > 0:
			var zebpaPos = Vector2(zebra.global_transform.origin.x, zebra.global_transform.origin.z)
			var playerPos = Vector2(G.player.global_transform.origin.x, G.player.global_transform.origin.z)
			
			var tempDist = zebpaPos.distance_to(playerPos)
			if tempDist < 50:
				return zebra


func _ready():
	spawners = get_node("spawners").get_children()


func _process(delta):
	if G.paused:
		music.set_stream_paused(true)
	else:
		if music_volume > 0 && music.get_stream_paused():
			music.set_stream_paused(false)
		if alarm_timer > 0: #--alarm--------------
			if attacking_count == 0:
				alarm_timer -= delta * 2
			else:
				alarm_timer -= delta
			
			if attacking_count < ALARM_ENEMIES_COUNT:
				if spawn_cooldown_timer > 0:
					spawn_cooldown_timer -= delta
				else:
					var spawned = false
					
					if spawners.size() > 0 && enemies_count < MAX_ALIVE:
						spawned = _spawnEnemy()
					if !spawned:
						var zebra = _getCloserZebra()
						if zebra:
							zebra.set_state("attack")
					spawn_cooldown_timer = SPAWN_COOLDOWN
		else: #--calm--------------------------------
			if !onetime_stop:
				stopAlarm()
			if attacking_count >= ALARM_ENEMIES_COUNT:
				startAlarm()

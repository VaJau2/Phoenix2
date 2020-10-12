extends "tradersBase.gd"

onready var faintManager = get_node("../../props/land/buildings/stealth/bars/playerPos")

export var playGuitar = false
var guitar 
var guitarSongs = []
var songI = 0
var songTimer = 0

export var hitSoundTimer = 0.6
export var gunOffPath: String
export var gunOnPath: String
var armed = false
var arming = false
var gunOn
var gunOff

var timer_get_weapon = 0
var timer_attack = 0


func _playNewSong():
	songTimer = guitarSongs[songI].get_length()
	audi.stream = guitarSongs[songI]
	audi.play()
	songI += 1


func _playGuitar(delta):
	if !guitar.is_visible():
		guitar.set_visible(true)
	anim.play("Guitar")
	if songTimer > 0:
		songTimer -= delta
	else:
		if songI == guitarSongs.size(): 
			songI = 0
			guitarSongs.shuffle()
		_playNewSong()


func _changeWeapon(animation:String, on: bool):
	_stop(true)
	arming = true
	anim.play(animation)
	yield(get_tree().create_timer(0.6),"timeout")
	if Health > 0:
		gunOff.visible = !on
		gunOn.visible = on
	yield(get_tree().create_timer(0.6),"timeout")
	armed = on
	arming = false


func set_state(new_state: String):
	if Health > 0 && !arming:
		if (new_state != "attack" && new_state != "seek") || aggressive:
			.set_state(new_state)
		else:
			state = 0
			
		if new_state == "idle":
			if armed:
				_changeWeapon("MacheteOff", false)
		if new_state == "attack" && aggressive:
			if playGuitar && guitar.is_visible():
				guitar.set_visible(false)
				audi.stop()
				songTimer = 0
			if !armed:
				_changeWeapon("TakeMachete", true)


func MakeDamage(temp_damage):
	_stop(true)
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	look_at(player_pos, Vector3.UP)
	
	anim.play(HitAnim)
	yield(get_tree().create_timer(hitSoundTimer),"timeout")
	if Health > 0:
		audi.stream = tryHitSound
		audi.play()
		var temp_dist = global_transform.origin.distance_to(player_pos)
		if temp_dist <= hitDistance:
			G.player.audi_hitted.stream = hitSound
			G.player.audi_hitted.play()
			.MakeDamage(temp_damage)
			if G.player.stats.Health > 0:
				faintManager.Faint()


func becomeAggressive():
	if playGuitar:
		guitar.visible = false
	.becomeAggressive()


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunOn.visible = false
		gunOff.visible = false
		if collar_key:
			dropItem(get_parent().collar_key, 1)
	
	becomeAggressive()
	.TakeDamage(damage)


func lookAtPlayer():
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	look_at(player_pos, Vector3.UP)


func seeAllyEvent(ally):
	if aggressive && !ally.aggressive:
		ally.aggressive = true


func _ready():
	tellOthersAboutPlayer = false
	gunOn = get_node(gunOnPath)
	gunOff = get_node(gunOffPath)
	if playGuitar:
		guitar = get_node("Armature/Skeleton/BoneAttachment 4/guitar")
		for i in range(6):
			var song = load("res://assets/audio/music/guitar/guitarSong" + str(i+1) + ".ogg")
			guitarSongs.append(song)
		guitarSongs.shuffle()


func _process(delta):
	if !aggressive:
		if playGuitar:
			_playGuitar(delta)
		return
	
	if handleImpulse():
		return

	if temp_cooldown > 0:
		count_timer_cooldown = true
		return
	else:
		count_timer_cooldown = false

	if Health > 0 && !G.paused && active:
		match state:
			0: #idle------
				if cameToPlace:
					global_transform.origin = my_start_pos
					if !playGuitar || !guitar.is_visible():
						anim.play(IdleAnim)
					else:
						_playGuitar(delta)
				else:
					goTo(my_start_pos)

			1: #attack----
				if playGuitar && guitar.is_visible():
					guitar.set_visible(false)
				
				if armed:
					goTo(G.player.global_transform.origin, true)
					if cameToPlace && seekArea.temp_player:
						MakeDamage(Damage)
						temp_cooldown = cooldown
					else:
						update_path = G.player.vel.length() > 2

			2: #seek------
				if playGuitar && guitar.is_visible():
					guitar.set_visible(false)
				
				if cameToPlace:
					if timer_seek_player > 0:
						count_timer_seek = true
					else:
						count_timer_seek = false
						set_state("idle")
				else:
					goTo(player_last_pos)
					timer_seek_player = 6
					count_timer_seek = false

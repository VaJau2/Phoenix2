extends "tradersBase.gd"

export var stayDistance: int
export var MissSound: AudioStream

export var gunOffPath: String
export var gunOnPath: String

var armed = false
var arming = false
var gunOn
var gunOff

var temp_distance
var close_to_player

export var dropWeapon: Resource
var gunFire
var gunLight
var gunSmoke

onready var gunAudi = get_node("audi")


func becomeAggressive():
	.becomeAggressive()
	if !aggressive:
		eyes.active = true
		eyes._updateEyes()


func _gunEffects():
	gunFire.visible = true
	gunLight.visible = true
	gunSmoke.restart()
	yield(get_tree().create_timer(0.2),"timeout")
	gunFire.visible = false
	gunLight.visible = false


func MakeDamage(temp_damage):
	_stop(true)
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	
	eyes._hitted()
	anim.play(HitAnim)
	gunAudi.stream = tryHitSound
	gunAudi.play()
	_gunEffects()

	if seePlayer && temp_distance <= hitDistance + 2:
		temp_damage = round(temp_damage / (temp_distance / 10))
		var temp_chance = SHOOT_CHANCE
		
		if G.player.vel.length() > 2:
			temp_chance = WALK_SHOOT_CHANCE
		
		if G.player.equipment.have_headrope:
			temp_chance -= 0.15
		
		if randf() > temp_chance:
			G.player.audi_hitted.stream = MissSound
			G.player.audi_hitted.play()
			return
		
		G.player.audi_hitted.stream = hitSound
		G.player.audi_hitted.play()
		.MakeDamage(temp_damage)


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunOn.set_visible(false)
		gunOff.set_visible(false)
		dropItem(dropWeapon, 1)
		if collar_key:
			dropItem(get_parent().collar_key, 1)
	
	becomeAggressive()
	.TakeDamage(damage)


func _ready():
	tellOthersAboutPlayer = false
	gunOn = get_node(gunOnPath)
	gunOff = get_node(gunOffPath)
	gunFire = gunOn.get_node("fire")
	gunLight = gunOn.get_node("light")
	gunSmoke = gunOn.get_node("smoke")
	if IdleAnim == "Sleep":
		eyes.active = false
		eyes.set_surface_material(0,eyes.closedEyes)


func _changeGun(animation:String, on: bool):
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
	if active && Health > 0 && !arming:
		if (new_state != "attack" && new_state != "seek") || aggressive:
			.set_state(new_state)
			cameToPlace = false
		else:
			state = 0
		
		if new_state == "idle":
			if armed:
				_changeGun("takeGun", false)
		if new_state == "attack" && aggressive:
			if !armed:
				_changeGun("putGun", true)


func _process(delta):
	._process(delta)
	if state == 1:
		temp_distance = global_transform.origin.distance_to(G.player.global_transform.origin)
		if temp_distance > stayDistance:
			close_to_player = false
			cameToPlace = false
	
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
					rotation = my_start_rot
					anim.play(IdleAnim)
				else:
					goTo(my_start_pos)

			1: #attack----
				if armed:
					if cameToPlace:
						close_to_player = true
					else:
						goTo(G.player.global_transform.origin, true)
					
					if close_to_player && seekArea.temp_player:
						var player_pos = G.player.global_transform.origin
						player_pos.y = global_transform.origin.y
						look_at(player_pos, Vector3.UP)
						
						if temp_cooldown <= 0:
							MakeDamage(Damage)
							temp_cooldown = cooldown
					else:
						update_path = G.player.vel.length() > 2

			2: #seek------
				if cameToPlace:
					if timer_seek_player > 0:
						count_timer_seek = true
					else:
						count_timer_seek = false
						set_state("idle")
				else:
					timer_seek_player = 6
					count_timer_seek = false
					goTo(player_last_pos, false, 0.5)

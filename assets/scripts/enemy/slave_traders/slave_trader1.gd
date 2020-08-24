extends "../zebra_base.gd"

const TIME_GET_WEAPON = 7
const TIME_ATTACK = 4

onready var start_point = get_node("../../props/bunker/laboratory/trader_start")
onready var follow_point = get_node("../../props/bunker/laboratory/trader_follow")
onready var stair_point = get_node("../../props/land/buildings/stealth/trader_stair") #иначе по лестнице он подниматься не хочет
onready var finish_point = get_node("../../props/land/buildings/stealth/trader_final")
onready var idle_point = get_node("../../props/land/buildings/stealth/trader_idle")
onready var prisonDoor = get_node("../../props/land/buildings/stealth/bars-door")
onready var faintManager = get_node("../../props/land/buildings/stealth/bars/playerPos")

onready var my_collar = get_node("Armature/Skeleton/BoneAttachment/collar")

var collarOnSound = preload("res://assets/audio/enemies/slave_traders/collarOn.wav")

export var hitSoundTimer = 0.6
export var gunOffPath: String
export var gunOnPath: String
var collar_key = true
var aggressive = false
var armed = false
var arming = false
var gunOn
var gunOff

var timer_get_weapon = 0
var timer_attack = 0


func putCollarOn():
	G.player.collar.visible = true
	G.player.collar.my_owner = self


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
	if !aggressive:
		get_parent().MakeEveryoneAngry()
		my_collar.visible = false
		aggressive = true
		active = true
		set_state("attack")


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunOn.visible = false
		gunOff.visible = false
		if !my_collar.is_visible():
			dropItem(get_parent().collar_key, 1)
		my_collar.set_visible(false)
	
	becomeAggressive()
	.TakeDamage(damage)


func lookAtPlayer():
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	look_at(player_pos, Vector3.UP)


func closePrison():
	active = false
	aggressive = false
	cameToPlace = false
	
	while(!cameToPlace && Health > 0 && !aggressive):
		if !G.paused:
			goTo(prisonDoor.global_transform.origin, false)
		yield(get_tree(),"idle_frame")
	
	if Health > 0 && !aggressive:
		if prisonDoor.open:
			prisonDoor.clickFurn("key_all")
		prisonDoor.my_key = "prison_key"
	
	active = true


func goAndCheck(point):
	var temp_dist = global_transform.origin.distance_to(G.player.global_transform.origin)
	if temp_dist < 18:
		if armed:
			if !arming:
				_changeWeapon("MacheteOff", false)
		else:
			goTo(point, false, 0.6)
			timer_get_weapon = TIME_GET_WEAPON
			timer_attack = TIME_ATTACK
	else:
		if vel.length() > 0:
			_stop()
		lookAtPlayer()
		if timer_get_weapon > 0:
			timer_get_weapon -= 0.05
		else:
			if !armed:
				if !arming:
					_changeWeapon("TakeMachete", true)
			else:
				if timer_attack > 0:
					timer_attack -= 0.05
				else:
					becomeAggressive()
					return


func _ready():
	tellOthersAboutPlayer = false
	scores = get_node("../../canvas/ResultMenu")
	gunOn = get_node(gunOnPath)
	gunOff = get_node(gunOffPath)
	my_start_pos = idle_point.global_transform.origin
	active = false
	yield(get_tree().create_timer(2, false),"timeout")
	#--- подходим к открывающейся капсуле
	while(!close_to_point):
		if !G.paused:
			moveTo(start_point.global_transform.origin, 4)
			anim.current_animation = "Walk"
		yield(get_tree(),"idle_frame")
	
	_stop()
	anim.current_animation = "Idle1"
	lookAtPlayer()
	close_to_point = false
	
	yield(get_tree().create_timer(5, false),"timeout")
	#--- подходим к игроку, чтоб надеть браслет
	while(!close_to_point && Health > 0 && !aggressive): 
		if !G.paused:
			moveTo(G.player.global_transform.origin, 4.5)
			anim.current_animation = "Walk"
			
			var temp_dist = global_transform.origin.distance_to(G.player.global_transform.origin)
			if temp_dist > 15 || seekArea.temp_player == null:
				becomeAggressive()
				return
		yield(get_tree(),"idle_frame")
	
	if Health > 0 && !aggressive:
		_stop()
		close_to_point = false
	else:
		return
	
	#--- надеваем браслет
	yield(get_tree().create_timer(0.15),"timeout")
	if Health > 0 && !aggressive: 
		G.player.mayMove = false
		my_collar.visible = false
		$audi.stream = collarOnSound
		$audi.play()
		yield(get_tree().create_timer(0.4),"timeout")
		putCollarOn()
		G.player.mayMove = true
	
	yield(get_tree().create_timer(0.2),"timeout")
	
	#--- идем к двери
	while(!close_to_point && Health > 0 && !aggressive):
		if !G.paused:
			moveTo(follow_point.global_transform.origin, 4)
			anim.current_animation = "Walk"
		yield(get_tree(),"idle_frame")
		
	yield(get_tree().create_timer(0.2),"timeout")
	if Health > 0 && !aggressive:
		_stop()
		anim.play("FollowMe")
		close_to_point = false
	else:
		return
	
	yield(get_tree().create_timer(1.8, false),"timeout")
	
	while(!cameToPlace && Health > 0 && !aggressive):
		if !G.paused:
			goAndCheck(stair_point.global_transform.origin)
		yield(get_tree(),"idle_frame")
	cameToPlace = false
	
	while(!cameToPlace && Health > 0 && !aggressive):
		if !G.paused:
			goAndCheck(finish_point.global_transform.origin)
		yield(get_tree(),"idle_frame")
	
	if Health > 0 && !aggressive:
		prisonDoor.clickFurn("key_all")
	var checkInside = prisonDoor.get_node("../bars/checkPlayerInside")
	
	while(Health > 0 && !aggressive && !checkInside.player_inside):
		if !G.paused:
			lookAtPlayer()
			var temp_dist = global_transform.origin.distance_to(G.player.global_transform.origin)
			if timer_get_weapon > 0 && temp_dist < 15:
				timer_get_weapon -= 0.05
			else:
				if !armed:
					if !arming:
						_changeWeapon("TakeMachete", true)
				else:
					if timer_attack > 0 && temp_dist < 20:
						timer_attack -= 0.05
					else:
						becomeAggressive()
						return
		yield(get_tree(),"idle_frame")
	
	if Health > 0 && !aggressive:
		if armed:
			if !arming:
				_changeWeapon("TakeMachete", false)
		prisonDoor.clickFurn("key_all")
		active = true


func _process(delta):
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
					anim.play(IdleAnim)
				else:
					goTo(my_start_pos)
		
			1: #attack----
				if armed:
					goTo(G.player.global_transform.origin, true)
					if cameToPlace && seekArea.temp_player:
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
					goTo(player_last_pos)

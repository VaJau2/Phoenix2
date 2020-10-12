extends "zebra_base.gd"

const SHOOT_CHANCE = 0.9
const WALK_SHOOT_CHANCE = 0.5

export var stayDistance: int
export var MissSound: AudioStream

var shogunPrefab = preload("res://objects/items/shotgun.tscn")

var temp_distance = 15
var close_to_player

onready var gunModel = get_node("Armature/Skeleton/BoneAttachment 3/shotgunBag/shotgun")
onready var gunFire = get_node("Armature/Skeleton/BoneAttachment 3/shotgunBag/shotgun/fire")
onready var gunLight = get_node("Armature/Skeleton/BoneAttachment 3/shotgunBag/shotgun/light")
onready var gunSmoke = get_node("Armature/Skeleton/BoneAttachment 3/shotgunBag/shotgun/smoke")
onready var gunAudi = get_node("audiShotgun")

func _gunEffects():
	gunFire.visible = true
	gunLight.visible = true
	gunSmoke.restart()
	yield(get_tree().create_timer(0.2),"timeout")
	gunFire.visible = false
	gunLight.visible = false


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunModel.visible = false
		dropItem(shogunPrefab, 1)
	.TakeDamage(damage)


func MakeDamage(temp_damage):
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	
	anim.play(HitAnim)
	gunAudi.stream = tryHitSound
	gunAudi.play()
	_gunEffects()
	
	var manager = get_parent()
	if manager.alarm_timer <= 0:
		manager.startAlarm()
	
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


func set_state(state: String):
	if Health > 0:
		.set_state(state)
		if state == "attack":
			cameToPlace = false

func _process(delta):
	._process(delta)
	if state == 1:
		temp_distance = global_transform.origin.distance_to(G.player.global_transform.origin)
		if temp_distance > stayDistance:
			close_to_player = false
			cameToPlace = false
	
	#раньше обрабатывалось в physics_process
	if handleImpulse():
		return

	count_timer_cooldown = temp_cooldown > 0

	if Health > 0 && !G.paused && active:
		match state:
			0: #idle------
				if patrolArray.size() == 0:
					goTo(my_start_pos)
					if cameToPlace:
						global_transform.origin = my_start_pos
						rotation = my_start_rot
						anim.play(IdleAnim)
				else:
					goTo(patrolArray[patrolI].global_transform.origin)
					if cameToPlace:
						if patrol_wait_timer > 0:
							count_patrol_timer = true
						else:
							if patrolI < patrolArray.size() - 1:
								patrolI += 1
							else:
								patrolI
							patrol_wait_timer = PATROL_WAIT
							count_patrol_timer = false

			1: #attack----
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
				goTo(player_last_pos)
				if cameToPlace:
					if timer_seek_player > 0:
						count_timer_seek = true
					else:
						count_timer_seek = false
						set_state("idle")
				else:
					timer_seek_player = 6
					count_timer_seek = false

extends "zebra_base.gd"

export var hitSoundTimer = 0.6
export var gunOffPath: String
export var gunOnPath: String

var armed = false
var gunOn
var gunOff

func _ready():
	gunOn = get_node(gunOnPath)
	gunOff = get_node(gunOffPath)


func _changeMachete(animation:String, on: bool):
	_stop()
	anim.play(animation)
	yield(get_tree().create_timer(0.7),"timeout")
	if Health > 0:
		gunOff.visible = !on
		gunOn.visible = on
	yield(get_tree().create_timer(0.8),"timeout")
	armed = on


func set_state(new_state: String):
	if Health > 0:
		.set_state(new_state)
		if new_state == "idle":
			if armed:
				_changeMachete("MacheteOff", false)
		if new_state == "attack":
			if !armed:
				_changeMachete("TakeMachete", true)


func MakeDamage(temp_damage):
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


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunOn.visible = false
		gunOff.visible = false
		
		if randf() < 0.27:
			var itemsManager = get_node("/root/Main/items")
			var randI = randi() % itemsManager.items.size() - 1
			var new_item = itemsManager.items[randI]
			dropItem(new_item, 1)
		
	.TakeDamage(damage)


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
								patrolI = 0
							patrol_wait_timer = PATROL_WAIT
							count_patrol_timer = false

			1: #attack----
				if armed:
					goTo(G.player.global_transform.origin, true)
					if cameToPlace && seekArea.temp_player:
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

extends "../zebra_base.gd"

const SHOOT_CHANCE = 0.9
const WALK_SHOOT_CHANCE = 0.5

export var stayDistance: int
export var MissSound: AudioStream

var shogunPrefab = preload("res://objects/items/shotgun.tscn")
var key = preload("res://objects/items/key.tscn")

var temp_distance = 15
var close_to_player

var aggressive = false

var collar_key = false

onready var gunModel = get_node("Armature/Skeleton/BoneAttachment 2/shotgunBag/shotgun")
onready var gunFire = get_node("Armature/Skeleton/BoneAttachment 2/shotgunBag/shotgun/fire")
onready var gunLight = get_node("Armature/Skeleton/BoneAttachment 2/shotgunBag/shotgun/light")
onready var gunSmoke = get_node("Armature/Skeleton/BoneAttachment 2/shotgunBag/shotgun/smoke")
onready var gunAudi = get_node("audiShotgun")

onready var prisonDoor = get_node("../../props/land/buildings/stealth/bars-door")


func becomeAggressive():
	if !aggressive:
		get_parent().MakeEveryoneAngry()
		aggressive = true
		active = true


func _gunEffects():
	gunFire.visible = true
	gunLight.visible = true
	gunSmoke.restart()
	yield(get_tree().create_timer(0.2),"timeout")
	gunFire.visible = false
	gunLight.visible = false


func dropKey():
	var item = key.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = global_transform.origin
	item.key_name = "prison_key"
	item.key_pick_text = "Подобран ключ от решетки"
	item.key_pick_text_eng = "Picked up the key to prison door"
	item.global_transform.origin.y += 1


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		gunModel.visible = false
		dropItem(shogunPrefab, 1)
		dropKey()
		if collar_key:
			dropItem(get_parent().collar_key, 1)
	
	becomeAggressive()
	.TakeDamage(damage)


func MakeDamage(temp_damage):
	_stop(true)
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


func set_state(new_state: String):
	if Health > 0:
		if (new_state != "attack" && new_state != "seek") || aggressive:
			.set_state(new_state)
		else:
			state = 0
		
		if new_state == "attack" && aggressive:
			cameToPlace = false


func _ready():
	tellOthersAboutPlayer = false


func _process(delta):
	._process(delta)
	if state == 1:
		temp_distance = global_transform.origin.distance_to(G.player.global_transform.origin)
		if temp_distance > stayDistance:
			close_to_player = false
			cameToPlace = false
	
	
	if !aggressive:
		return
	
	if handleImpulse():
		return

	count_timer_cooldown = temp_cooldown > 0

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
					goTo(player_last_pos)

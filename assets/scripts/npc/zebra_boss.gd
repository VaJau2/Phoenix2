extends "zebra_base.gd"

const SHOOT_CHANCE = 0.9
const WALK_SHOOT_CHANCE = 0.5

export var stayDistance: int
export var MissSound: AudioStream

export var gunOffPath: String
export var gunOnPath: String

var armed = false
var gunOn
var gunOff

var temp_distance
var close_to_player

var revolverPrefab = preload("res://objects/items/revolver.tscn")

onready var gunFire = get_node("Armature/Skeleton/BoneAttachment 2/revolver/fire")
onready var gunLight = get_node("Armature/Skeleton/BoneAttachment 2/revolver/light")
onready var gunSmoke = get_node("Armature/Skeleton/BoneAttachment 2/revolver/smoke")
onready var gunAudi = get_node("audiRevolver")

onready var dragon = get_node("../dragon")

var save = true

func _gunEffects():
	gunFire.visible = true
	gunLight.visible = true
	gunSmoke.restart()
	yield(get_tree().create_timer(0.2),"timeout")
	gunFire.visible = false
	gunLight.visible = false
	

func MakeDamage(temp_damage):
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	
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
		gunOn.visible = false
		gunOff.visible = false
		dropItem(revolverPrefab, 1)
		if save:
			get_node("/root/Main/loadingManager").saveGame()
		get_parent().activateDragon()
	.TakeDamage(damage)


func _ready():
	gunOn = get_node(gunOnPath)
	gunOff = get_node(gunOffPath)
	active = false


func _changeGun(animation:String, on: bool):
	_stop()
	anim.play(animation)
	yield(get_tree().create_timer(0.7),"timeout")
	if Health > 0:
		gunOff.visible = !on
		gunOn.visible = on
	yield(get_tree().create_timer(0.8),"timeout")
	armed = on


func set_state(new_state: String):
	if active && Health > 0:
		.set_state(new_state)
		if new_state == "idle":
			if armed:
				_changeGun("putRevolver", false)
		if new_state == "attack":
			if !armed:
				_changeGun("getRevolver", true)


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
	
	if temp_cooldown > 0:
		count_timer_cooldown = true
		return
	else:
		count_timer_cooldown = false
	
	if Health > 0 && !G.paused && active:
		match state:
			0: #idle------
				goTo(my_start_pos)
				if cameToPlace:
					global_transform.origin = my_start_pos
					rotation = my_start_rot
					anim.play(IdleAnim)

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

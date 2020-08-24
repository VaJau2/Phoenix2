extends "zebra_base.gd"

const SHOOT_CHANCE = 0.95
const WALK_SHOOT_CHANCE = 0.7
const AIM_TIMER = 0.8

export var rifle_path: NodePath
var rifle

var aimTimer: float
export var MissSound: AudioStream

var riflePrefab = preload("res://objects/items/rifle.tscn")
onready var gunFire
onready var gunLight
onready var gunSmoke
onready var gunAudi = get_node("audiRifle")


func TakeDamage(damage: int, shapeID = 0):
	if Health - damage <= 0:
		rifle.visible = false
		dropItem(riflePrefab, 6.5, true)
	.TakeDamage(damage)
	

func MakeDamage(temp_damage):
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	rifle.look_at(player_pos, Vector3.UP)
	
	var temp_distance = global_transform.origin.distance_to(player_pos)
	
	gunAudi.stream = tryHitSound
	gunAudi.play()
	_gunEffects()

	if seePlayer:
		temp_damage = round(temp_damage / (temp_distance / 100))
		var temp_chance = SHOOT_CHANCE
		if G.player.vel.length() > 2:
			temp_chance = WALK_SHOOT_CHANCE
		if randf() > SHOOT_CHANCE:
			G.player.audi_hitted.stream = MissSound
			G.player.audi_hitted.play()
			return
		
		G.player.audi_hitted.stream = hitSound
		G.player.audi_hitted.play()
		.MakeDamage(temp_damage)


func _gunEffects():
	gunFire.visible = true
	gunLight.visible = true
	gunSmoke.restart()
	yield(get_tree().create_timer(0.2),"timeout")
	gunFire.visible = false
	gunLight.visible = false


func set_state(new_state: String):
	if Health > 0:
		.set_state(new_state)
		if new_state == "attack":
			if !seekArea.temp_player:
				set_state("seek")
			aimTimer = AIM_TIMER
		if new_state == "seek":
			timer_seek_player = 1


func _ready():
	._ready()
	rifle = get_node(rifle_path)
	gunFire = rifle.get_node("fire")
	gunLight = rifle.get_node("light")
	gunSmoke = rifle.get_node("smoke")
	mayBeMeat = false


func _process(delta):
	._process(delta)
	if aimTimer > 0:
		aimTimer -= delta
	
	
	count_timer_cooldown = temp_cooldown > 0
	if temp_cooldown > 0:
		return

	if Health > 0 && !G.paused && active:
		match state:
			0: #idle------
				anim.play("Sit")
			1: #attack----
				anim.play("Idle1")
				if aimTimer <= 0 && seekArea.temp_player:
					var player_pos = G.player.global_transform.origin
					player_pos.y = global_transform.origin.y
					rifle.look_at(player_pos, Vector3.UP)

					if temp_cooldown <= 0:
						MakeDamage(Damage)
						temp_cooldown = cooldown

			2: #seek------
				anim.play("Idle1")
				if timer_seek_player > 0:
					count_timer_seek = true
				else:
					count_timer_seek = false
					set_state("idle")

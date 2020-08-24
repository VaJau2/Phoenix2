extends "enemy_base.gd"

const PATROL_WAIT = 3
const RUN_DISTANCE = 12

export var RunSpeed: int
export var IdleAnim: String
export var HitAnim: String
export var patrolArray: Array
export var tryHitSound: AudioStream
export var hitSound: AudioStream

export var hittedSound: Array
export var deadSound: AudioStream

onready var navigation = get_node("/root/Main/Navigation")
onready var seekArea = get_node("seekArea")
onready var eyes = get_node("Armature/Skeleton/Body")

var meatParts = preload("res://objects/enemies/meat/MeatParts.tscn")

var state = 0

var path
var pathI = 0
var pointToGo = null
var cameToPlace = false

var seePlayer = false
var player_last_pos = Vector3(0,0,0)
var my_start_pos = Vector3(0,0,0)
var my_start_rot = Vector3(0,0,0)
var patrolI = 0
var patrol_wait_timer = PATROL_WAIT
var count_patrol_timer = false
var timer_seek_player = 5
var count_timer_seek = false
var count_timer_cooldown = false
var update_path = false
var update_path_timer = 1
var other_zebras = []
var attackCountIncreased = false
var mayBeMeat = true
var running = false
var tellOthersAboutPlayer = true

var door_wait = 0

var huh_sounds = [
	preload("res://assets/audio/enemies/huh1.wav"),
	preload("res://assets/audio/enemies/huh2.wav"),
	preload("res://assets/audio/enemies/huh3.wav"),
]


func dropItem(item_prefab, item_height, item_down = false):
	var item = item_prefab.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = global_transform.origin
	
	if !item_down:
		item.global_transform.origin.y += item_height
	else:
		var side_x = randf() - 0.5
		var side_z = randf() - 0.5
		var wr = weakref(item)
		while(item_height > 0 && wr.get_ref()):
			item.global_transform.origin.x += side_x * 0.5
			item.global_transform.origin.z += side_z * 0.5
			item.global_transform.origin.y -= 0.4
			item_height -= 0.4
			yield(get_tree(),"idle_frame")


func _changeAttackCount(increase: bool):
	if "attacking_count" in get_parent():
		if increase && !attackCountIncreased:
			get_parent().attacking_count += 1
			attackCountIncreased = true
		if !increase && attackCountIncreased:
			get_parent().attacking_count -= 1
			attackCountIncreased = false


func set_state(new_state: String):
	if Health > 0:
		cameToPlace = false
		
		if new_state == "idle":
			path = null
			if state != 0:
				seekArea.seeTimer = seekArea.SEE_TIMER
				seePlayer = false
				G.player.stealth.removeAttackEnemy(self)
				G.player.stealth.removeSeekEnemy(self)
			state = 0
		
		elif new_state == "attack":
			_changeAttackCount(true)
			path = null
			if state == 0:
				var huh_i = randi() % huh_sounds.size()
				audi.stream = huh_sounds[huh_i]
				audi.play()
			state = 1
			timer_seek_player = 0
			seePlayer = true
			G.player.stealth.addAttackEnemy(self)
			if "attacking_count" in get_parent() && tellOthersAboutPlayer:
				if get_parent().attacking_count < 4:
					if other_zebras.size() > 0:
						for zebra in other_zebras:
							if !zebra.seePlayer && zebra.state != 1:
								zebra.set_state("attack")
								yield(get_tree(),"idle_frame")
			
		elif new_state == "seek":
			G.player.stealth.addSeekEnemy(self)
			_changeAttackCount(false)
			seePlayer = false
			state = 2
		else:
			print("what is " + new_state + "?")


func TakeDamage(damage: int, shapeID = 0):
	.TakeDamage(damage)
	if Health == 0:
		if state != 0:
			G.player.stealth.removeAttackEnemy(self)
			G.player.stealth.removeSeekEnemy(self)
		
		_changeAttackCount(false)
		if "enemies_count" in get_parent():
			get_parent().enemies_count -= 1
		audi.stream = deadSound
		audi.play()
		vel = Vector3(0,0,0)
		
		var num = randi() % 2 + 1
		anim.play("Die" + str(num))
		set_collision_layer(0)
		set_collision_mask(0)
		if damage > 100 && randf() > 0.3 && mayBeMeat:
			scores.score_reasons.Meat_Kill += 1
			
			var new_meat = meatParts.instance()
			get_node("/root/Main").add_child(new_meat)
			new_meat.global_transform.origin = global_transform.origin
			queue_free()
		else:
			if "alarmed" in get_parent() && !get_parent().alarmed:
				scores.score_reasons.Stealth_Kill += 1
			else:
				scores.score_reasons.Kill += 1
			
			yield(get_tree().create_timer(2, false),"timeout")
			anim.queue_free()
			get_parent().addDead(self)
	else:
		if state != 1:
			var black_screen = G.player.stats.black_screen
			if !black_screen.is_visible():
				set_state("attack")
				if !tellOthersAboutPlayer && other_zebras.size() > 0:
					if !other_zebras[0].seePlayer && other_zebras[0].state != 1:
						other_zebras[0].set_state("attack")
					
		if "_hitted" in eyes:
			eyes._hitted()
		if hittedSound.size() > 0:
			var soundI = randi() % hittedSound.size()
			audi.stream = hittedSound[soundI]
			audi.play()


func goTo(place: Vector3, goToPlayer = false, come_dist = COME_DIST):
	cameToPlace = false
	var pos = global_transform.origin
	
	var distance = come_dist + 1
	if goToPlayer:
		distance = hitDistance
	var temp_distance = pos.distance_to(place)
	
	if !goToPlayer || seekArea.temp_player:
		if temp_distance < distance:
			_stop()
			cameToPlace = true
			return
	
	if path == null:
		path = navigation.get_simple_path(pos, place, true)
		pathI = 0
	
	if door_wait > 0:
		door_wait -= 0.05
		_stop()
		return
	
	if path.size() == 0:
		_stop()
		return
	
	if goToPlayer && temp_distance > RUN_DISTANCE:
		anim.play("Run")
		moveTo(path[pathI], COME_DIST, RunSpeed)
		running = true
	else:
		anim.play("Walk")
		moveTo(path[pathI], COME_DIST, Speed)
		running = false
	
	if close_to_point:
		if pathI < path.size() - 1:
			pathI += 1
		else:
			cameToPlace = true
			_stop()


func _stop(move_down = false):
	anim.play("Idle1")
	path = null
	pathI = 0
	if move_down:
		vel = Vector3(0,-GRAVITY,0)
	else:
		vel = Vector3(0,0,0)


func _ready():
	if IdleAnim.length() > 0:
		anim.play(IdleAnim)
	
	if patrolArray.size() == 0:
		my_start_pos = global_transform.origin
		my_start_rot = rotation
	else:
		for patrolPathI in patrolArray.size():
			patrolArray[patrolPathI] = get_node(patrolArray[patrolPathI])
	scores = get_node("../../canvas/ResultMenu")


func _process(delta):
	if count_timer_seek:
		if timer_seek_player > 0:
			timer_seek_player -= delta
	
	if count_timer_cooldown:
		if temp_cooldown > 0:
			temp_cooldown -= delta
	
	if count_patrol_timer:
		if patrol_wait_timer > 0:
			patrol_wait_timer -= delta
	
	if update_path:
		if update_path_timer > 0:
			update_path_timer -= delta
		else:
			path = null
			update_path_timer = 1
			update_path = false

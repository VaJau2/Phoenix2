extends Spatial

const ALARM_TIME = 200
const ALARM_ENEMIES_COUNT = 3
const ALARM_FAR_DIST = 60
const MAX_DEAD = 6
const ANGRY_COOLDOWN = 5

var enemies_count = 12

var dead_array = []
var alarmed = false
var alarm_timer = 0
var attacking_count = 0
var onetime_stop = false

var angry_cooldown_timer = 0

var collar_key = preload("res://objects/items/collar-key.tscn")
var enemyCorpse = preload("res://objects/enemies/slave_traders/enemyCorpse.tscn")
onready var corpsePos = get_node("/root/Main/props/land/player_corpses")

func MakeEveryoneAngry():
	for trader in get_children():
		if trader.Health > 0:
			trader.aggressive = true


func MakeEveryoneCalm(teleport = false):
	for trader in get_children():
		if trader.Health > 0:
			trader.aggressive = false
			trader.set_state("idle")
			if teleport && trader.patrolArray.size() == 0:
				if trader.patrolArray.size() == 0:
					trader.global_transform.origin = trader.my_start_pos
				else:
					trader.global_transform.origin = trader.patrolArray[trader.patrolI].global_transform.origin
				trader.anim.play(trader.IdleAnim)
				trader._stop()


func MakeEveryoneIdle(teleport = false):
	for trader in get_children():
		if trader.Health > 0:
			trader.set_state("idle")
			if teleport:
				if trader.patrolArray.size() == 0:
					trader.global_transform.origin = trader.my_start_pos
				else:
					trader.global_transform.origin = trader.patrolArray[trader.patrolI].global_transform.origin
				trader.anim.play(trader.IdleAnim)
				trader._stop()


func SetCloserAngry():
	var closerTrader = _getCloserTrader()
	if closerTrader:
		closerTrader.aggressive = true
		closerTrader.set_state("attack")


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


func CheckDead():
	var slaves = get_node("../slaves").get_children()
	for _slave in slaves:
		if _slave.Health <= 0:
			_moveDead(_slave)
	if dead_array.size() > 0:
		for dead in dead_array:
			_moveDead(dead)
		dead_array.clear()


func _moveDead(body):
	var armature = body.get_node("Armature")
	var newCorpse = enemyCorpse.instance()
	get_node("/root/Main").add_child(newCorpse)
	var randX = (randf() - 0.5) * 4
	var randZ = (randf() - 0.5) * 4
	var cPos = corpsePos.global_transform.origin
	newCorpse.global_transform.origin = Vector3(cPos.x + randX, cPos.y + 0.1, + cPos.z + randZ)
	body.remove_child(armature)
	newCorpse.add_child(armature)
	armature.translation = Vector3.ZERO
	armature.rotation = Vector3.ZERO
	body.queue_free()


func startAlarm():
	if !alarmed:
		onetime_stop = false
		alarm_timer = ALARM_TIME
		alarmed = true


func stopAlarm():
	onetime_stop = true


func _getCloserTrader():
	for trader in get_children():
		if trader.Health > 0:
			var traderPos = Vector2(trader.global_transform.origin.x, trader.global_transform.origin.z)
			var playerPos = Vector2(G.player.global_transform.origin.x, G.player.global_transform.origin.z)
			
			var tempDist = traderPos.distance_to(playerPos)
			if tempDist < 50:
				return trader


func _process(delta):
	if enemies_count > 0:
		if alarm_timer > 0: #--alarm--------------
			if attacking_count == 0:
				alarm_timer -= delta * 2
			else:
				alarm_timer -= delta
			
			if attacking_count < ALARM_ENEMIES_COUNT:
				if angry_cooldown_timer > 0:
					angry_cooldown_timer -= delta
				else:
					var enemy = _getCloserTrader()
					if enemy:
						enemy.set_state("attack")
					angry_cooldown_timer = ANGRY_COOLDOWN
		else: #--calm--------------------------------
			if !onetime_stop:
				stopAlarm()
			if attacking_count >= ALARM_ENEMIES_COUNT:
				startAlarm()

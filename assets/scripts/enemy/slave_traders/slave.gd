extends "../zebra_base.gd"

export var stayDistance: int
export var otherPath: NodePath
var otherSlave = null
onready var otherRay = get_node("otherSlaveRay")
var seeOtherSlave = false
onready var awayPoint = get_node("/root/Main/props/land/awayPoint")
var collarSound = preload("res://assets/audio/enemies/slave_traders/collarOff.wav")

var collared = true
var waiting = false
var close_to_player = false
var temp_distance = 15

var runAway = false


func changeCollar(on: bool):
	if !on:
		audi.stream = collarSound
		audi.play()
		if  scores.score_reasons.Slaves > 1:
			if otherSlave.collared:
				scores.score_reasons.Slaves = 3
			else:
				scores.score_reasons.Slaves = 4
	
	$"Armature/Skeleton/BoneAttachment 2/collar".visible = on
	collared = on


func set_state(new_state: String):
	pass


func checkOtherSlave():
	otherRay.enabled = true
	seeOtherSlave = false
	var dir = otherSlave.global_transform.origin - global_transform.origin
	otherRay.global_transform.basis = Basis(Vector3.ZERO)
	otherRay.set_cast_to(dir)
	if otherRay.is_colliding():
		var body = otherRay.get_collider()
		if "collared" in body:
			seeOtherSlave = true


func TakeDamage(damage: int, shapeID = 0, not_player = false):
	if collared && !not_player:
		get_node("../../enemies").SetCloserAngry()
		
	if seeOtherSlave:
		otherSlave.cameToPlace = false
		otherSlave.path = null
		otherSlave.runAway = true
	
	if Health > damage:
		Health -= damage
	else:
		Health = 0
	
	if Health == 0:
		if otherSlave.Health > 0:
			scores.score_reasons.Slaves = 1
		else:
			scores.score_reasons.Slaves = 0
		
		audi.stream = deadSound
		audi.play()
		_stop()
		var num = randi() % 2 + 1
		anim.play("Die" + str(num))
		set_collision_layer(0)
		set_collision_mask(0)
		yield(get_tree().create_timer(2),"timeout")
		anim.queue_free()
		if "addDead" in get_parent():
			get_parent().addDead(self)
	else:
		if "_hitted" in eyes:
			eyes._hitted()
		if hittedSound.size() > 0:
			var soundI = randi() % hittedSound.size()
			audi.stream = hittedSound[soundI]
			audi.play()


func lookAtPlayer():
	var player_pos = G.player.global_transform.origin
	player_pos.y = global_transform.origin.y
	look_at(player_pos, Vector3.UP)


func moveToPrison():
	if Health > 0:
		global_transform.origin = my_start_pos
		rotation = my_start_rot
		anim.play(IdleAnim)
		changeCollar(true)


func runTo(place: Vector3, come_dist = COME_DIST):
	cameToPlace = false
	var pos = global_transform.origin
	
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
	
	anim.play("Run")
	moveTo(path[pathI], come_dist, RunSpeed)
	running = true
	
	if close_to_point:
		if pathI < path.size() - 1:
			pathI += 1
		else:
			cameToPlace = true
			_stop()


func _ready():
	scores = get_node("../../canvas/ResultMenu")
	otherSlave = get_node(otherPath)
	my_start_pos = global_transform.origin
	my_start_rot = rotation


func _process(delta):
	._process(delta)
	
	if handleImpulse():
		return
	
	if Health > 0 && !G.paused && active:
		if collared:
			if "collared" in otherSlave && otherSlave.collared && otherSlave.Health > 0:
				anim.play(IdleAnim)
			else:
				anim.play("Sit")
		else:
			checkOtherSlave()
			#--убегаем за карту
			if runAway: 
				if cameToPlace:
					queue_free()
				else:
					runTo(awayPoint.global_transform.origin)
					return
			
			#--ждем
			if waiting:
				if vel.length() > 0:
					_stop()
				return
			
			#--идем за игроком
			if cameToPlace:
				temp_distance = global_transform.origin.distance_to(G.player.global_transform.origin)
				if temp_distance > stayDistance:
					close_to_player = false
					cameToPlace = false
				else:
					close_to_player = true
			else:
				goTo(G.player.global_transform.origin, false, 4)
			
			if close_to_player:
				var player_pos = G.player.global_transform.origin
				player_pos.y = global_transform.origin.y
				look_at(player_pos, Vector3.UP)
			else:
				update_path = G.player.vel.length() > 2

extends "enemy_base.gd"

const SEE_TIMER = 1
const ATTACK_COOLDOWN = 2
const MOUTH_DAMAGE = 20
const FIRE_DAMAGE = 20

var idle_sounds = [
	preload("res://assets/audio/enemies/dragon/dragon-growl.wav"),
	preload("res://assets/audio/enemies/dragon/dragon-roar.wav")
]
var idle_timer = 5

var hitted_sounds = [
	preload("res://assets/audio/enemies/dragon/dragon-hurt1.wav"),
	preload("res://assets/audio/enemies/dragon/dragon-hurt2.wav")
]
var dead_sound = preload("res://assets/audio/enemies/dragon/dragon-die.wav")

export var roundPointsPath: Array
var roundPoints = []
var pointI = 0
var onetimeAnim = false

onready var mouthPos = get_node("Armature/Skeleton/BoneAttachment/mouth")
onready var playerRay = get_node("playerRay")
var seePlayer = false
var player_distance = 0
var seeTimer = SEE_TIMER
var attacking = false
var smash_attack = true
var player_in_mouth = false
var player_in_mouth_timer = 0
var damage_timer = 3
var mouth_shoot = false

var start_falling = false
var falling = true
var onetime_die = false

#-- штуки для дыхания огнем
onready var fireObj = get_node("Armature/Skeleton/BoneAttachment/mouth/fire")
onready var fireParts = [
	get_node("Armature/Skeleton/BoneAttachment/mouth/fire/Particles"),
	get_node("Armature/Skeleton/BoneAttachment/mouth/fire/Particles2"),
	get_node("Armature/Skeleton/BoneAttachment/mouth/fire/Particles3")
]
onready var fireAnim = get_node("Armature/Skeleton/BoneAttachment/mouth/fire/fireAnim")
onready var audiFire = get_node("audi-fire")
var fireSound = preload("res://assets/audio/enemies/dragon/dragon-fire.wav")
var fire_distance = 50
var fire_close = false
var fire_wait_timer = 1
var fire_timer = 3.5

#-- полоска ХП
onready var healthBarObj = get_node("/root/Main/canvas/gragonHealth")
onready var healthBar = get_node("/root/Main/canvas/gragonHealth/ProgressBar")

onready var bombs = get_node("/root/Main/props/bombs")


func TakeDamage(damage: int, shapeID = 0):
	.TakeDamage(damage)
	
	#if player_in_mouth:
	#	player_in_mouth_timer -= 1
	
	if Health > 0:
		if !healthBarObj.visible:
			healthBarObj.visible = true
		healthBar.value = Health
		if randf() < 0.6:
			audi.stream = hitted_sounds[randi() % hitted_sounds.size()]
			audi.play()
	else:
		scores.score_reasons.Kill += 1
		G.player.stealth.removeAttackEnemy(self)
		
		healthBarObj.visible = false
		get_parent().stopAlarm()
		if player_in_mouth:
			_letPlayerGo()
		
		get_node("audi-wings").stop()
		_fireOn(false)
		audi.stream = dead_sound
		audi.play()
		vel.x /= 1.5
		vel.z /= 1.5
		yield(get_tree().create_timer(.7),"timeout")
		start_falling = true
		yield(get_tree().create_timer(3),"timeout")
		falling = false
		yield(get_tree().create_timer(4),"timeout")
		bombs.startWar()


func _animFlying():
	onetimeAnim = true
	if player_in_mouth:
		anim.play("fly-open-mouth")
	else:
		var rotY1 = rotation.y
		yield(get_tree().create_timer(0.1), "timeout")
		var rotY2 = rotation.y
		if rotY2 < rotY1:
			if anim.get_current_animation() != "fly-right":
				anim.play("fly-right")
		elif rotY2 > rotY1:
			if anim.get_current_animation() != "fly-left":
				anim.play("fly-left")
		else:
			anim.play("fly")
	onetimeAnim = false


func _checkSeePlayer():
	var player_pos = G.player.global_transform.origin
	player_pos.y += 1
	var dir = player_pos - global_transform.origin
	
	playerRay.global_transform.basis = Basis(Vector3.ZERO)
	playerRay.set_cast_to(dir)
	if playerRay.is_colliding():
		if playerRay.get_collider() == G.player:
			seePlayer = true
			return
	seePlayer = false


func _updateSeeTimer(delta:float, result:bool):
	if seeTimer > 0:
		seeTimer -= delta
	else:
		seeTimer = SEE_TIMER
		attacking = result
		if result:
			smash_attack = randf() > 0.6
			if !smash_attack:
				damage_timer = 0.5
			else:
				damage_timer = 3
		else:
			if fire_timer > 0:
				_fireOn(false)


func _changeHeight(speed, need_height):
	if translation.y > need_height + 1:
		GRAVITY = speed
	elif translation.y < need_height - 1:
		GRAVITY = -speed
	else:
		GRAVITY = 0


func _lookAtPlayer():
	var pos = G.player.global_transform.origin
	pos.y = global_transform.origin.y
	look_at(pos, Vector3.UP)


func _fireOn(on):
	for fire in fireParts:
		fire.set_emitting(on)
	if on:
		audiFire.stream = fireSound
		audiFire.play()
		fireAnim.play("fire")
	else:
		audiFire.stop()
		fireAnim.set_current_animation("[stop]")
		fireObj.get_node("sprite").frame = 0
		fireObj.get_node("sprite2").frame = 0
		fireObj.get_node("sprite3").frame = 0


func checkMouthShoot():
	if !mouth_shoot:
		if G.player.weapons.onetimeShoot:
			mouth_shoot = true
			player_in_mouth_timer -= 1
	else:
		yield(get_tree().create_timer(0.2),"timeout")
		mouth_shoot = false


func _letPlayerGo():
	player_in_mouth = false
	G.player.mayMove = true
	G.player.set_collision_layer(1)
	G.player.set_collision_mask(1)
	G.player.rotation_degrees = Vector3(0, G.player.rotation_degrees.y,0)
	var impulse = -global_transform.basis.z * 3 + Vector3(0, -1, 0)
	G.player.impulse = impulse


func _ready():
	active = false
	rotation_speed = 0.05
	GRAVITY = 0
	
	for point in roundPointsPath:
		roundPoints.append(get_node(point).global_transform.origin)
	scores = get_node("../../canvas/ResultMenu")


func _process(delta):
	if !G.paused && active:
		if Health > 0:
			#--- кастуем луч на игрока
			_checkSeePlayer()
			if seePlayer:
				player_distance = global_transform.origin.distance_to(G.player.global_transform.origin)
			
			#-- кулдаун дыхания огнем и увеличение доступного расстояния
			if fire_close:
				if player_distance > fire_distance:
					fire_close = false
					close_to_point = false
					_fireOn(false)
				else:
					if fire_wait_timer > 0:
						vel = Vector3(0,0,0)
						fire_wait_timer -= delta
						anim.play("fly-on-place")
						_lookAtPlayer()
					else:
						if !audiFire.is_playing():
							anim.play("attack")
							_fireOn(true)
						
						if fire_timer > 0:
							fire_timer -= delta
							_lookAtPlayer()
							
							if seePlayer:
								if damage_timer > 0:
									damage_timer -= delta
								else:
									G.player.stats.TakeDamage(FIRE_DAMAGE, Vector3.ZERO)
									damage_timer = 0.5
						else:
							_fireOn(false)
							fire_wait_timer = 1
							fire_timer = 3.5
							attacking = false
							seeTimer = ATTACK_COOLDOWN
							fire_close = false
			else:
				if !attacking:
					#--- издаем звуки
					if idle_timer > 0:
						idle_timer -= delta
					else:
						audi.stream = idle_sounds[randi() % idle_sounds.size()]
						audi.play()
						idle_timer = randf() * 10 + 2
					
					#--- летаем по кругу
					if !close_to_point:
						moveTo(roundPoints[pointI], 20)
						
						if !onetimeAnim: #типа динамично определяем сторону полета
							_animFlying() #определяя скорость поворота
					else:
						if pointI < roundPoints.size() - 1:
							pointI += 1
						else:
							pointI = 0
						close_to_point = false
					
					#обрабатываем игрока, когда кушаем его
					if player_in_mouth_timer > 0:
						checkMouthShoot()
						
						G.player.global_transform.origin = mouthPos.global_transform.origin
						G.player.rotation_degrees = Vector3(0, rotation_degrees.y + 90 ,-90)
						G.player.body.body_rot = 0
						
						if damage_timer > 0:
							damage_timer -= delta
						else:
							damage_timer = 3
							G.player.stats.TakeDamage(MOUTH_DAMAGE, Vector2(0,0), true)
					else:
						if player_in_mouth:
							_letPlayerGo()
						
						if seePlayer:
							_updateSeeTimer(delta, true)
					_changeHeight(1 * Speed, 40)
				else:
					#--снижаемся к игроку на разную высоту, в зависимости от режима
					var new_height = 16 
					if smash_attack:
						new_height = 8
					if player_distance < 60:
						_changeHeight(2 * Speed, G.player.translation.y + new_height)
					
					#теряем его из виду, если тот пропал
					if !seePlayer:
						_updateSeeTimer(delta, false)
					
					#--- летим на игрока
					if !close_to_point:
						var distance = 20
						if smash_attack:
							distance = 4
						moveTo(G.player.global_transform.origin, distance)
						if !onetimeAnim: #типа динамично определяем сторону полета
							_animFlying() #определяя скорость поворота
					else:
						if smash_attack:
							attacking = false
							seeTimer = ATTACK_COOLDOWN
						else:
							fire_close = true
		else:
			if falling:
				anim.play("die1")
				if start_falling:
					vel.x /= 2
					vel.y = -2 * Speed
					vel.z /= 2
			else:
				if !onetime_die:
					anim.play("die2")
					#set_collision_layer(0)
					#set_collision_mask(0)
					onetime_die = true

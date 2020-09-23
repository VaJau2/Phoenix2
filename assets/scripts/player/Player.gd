extends KinematicBody

onready var stats = get_node("stats")
onready var stealth = get_node("stealthManager")
onready var body = get_node("player_body")
onready var weapons = get_node("gunsManager")
onready var audi = get_node("audi")
onready var audi_hitted = get_node("audi_hitted")

export var have_pistol = false
export var have_coat = false
export var check_clone_flask = false

var mayMove = true
var hitting = false

var thirdView = false
var lying = false #ограничение для вращения тела
var roped = false
var unroping = 0
var unroping_sound = preload("res://assets/audio/enemies/ropes/unroping.wav")
var unroped_sound = preload("res://assets/audio/enemies/ropes/unroped.wav")

var OnStairs = false #лестничный костыль
var stairGravity = 0

var running = false
var crouching = false
var body_collider_size = 1

const GRAVITY = -50
var vel = Vector3()
var MAX_SPEED = 17
var RUN_SPEED = 30.0
const JUMP_SPEED = 18
const ACCEL = 5.5

var dir = Vector3()
var sideAngle = 0

var impulse = Vector3()

var crouch_cooldown = 0.0

const DEACCEL= 12
const MAX_SLOPE_ANGLE = 50

var camera
var camera_head_pos
var rotation_helper_third
var body_follows_camera = false
var rotation_helper
var body_collider
var body_collider_2
var collar

var MOUSE_SENSITIVITY = 0.1

var shaking_speed = 0
var shakeUp = false
const SHAKE_TIME = 0.1
var shake_timer = 0

var tempRay
onready var horn_particles = get_node("player_body/Armature/Skeleton/BoneAttachment/horn/Particles")
var teleport_mark = preload("res://objects/magic/TeleportMark.tscn")
var teleport_effect = preload("res://objects/magic/TeleportEffect.tscn")
var teleport_sound = preload("res://assets/audio/magic/teleporting.wav")
var temp_teleport_mark
var teleport_pressed = false
var start_teleporting = false
var jump_hint
var teleport_inside = false

var flying = false
var flying_fast = false
var speedY = 0
var flySpeed = 30.0
var fly_increase = 5.0
var fly_decrease = 4
var wings_sound = preload("res://assets/audio/flying/pegasus-wings.wav")
var wind_sound = preload("res://assets/audio/flying/wind.wav")

var not_socks_material = preload("res://assets/materials/player/player_body.material")
var socks_material = preload("res://assets/materials/player/player_body_socks.material")

var equipment = {
	"have_armor": false,
	"have_socks": false,
	"have_bandage": false,
	"have_headrope": false
}


func _ready():
	G.player = self
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	body_collider = $body_shape
	body_collider_2 = $shape
	camera_head_pos = $player_body/Armature/Skeleton/BoneAttachment/cameraPos
	rotation_helper_third = $Rotation_Helper_Third
	collar = body.get_node("Armature/Skeleton/collar")
	jump_hint = get_node("/root/Main/canvas/jumpHint")
	
	MOUSE_SENSITIVITY = G.sensivity
	rotation_helper_third.first_camera.set_zfar(G.distance)
	rotation_helper_third.third_camera.set_zfar(G.distance)
	
	loadRace()
	
	if have_coat:
		$"player_body/Armature/Skeleton/BoneAttachment/hat".visible = true
		$"player_body/Armature/Skeleton/coat".visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	yield(get_tree(),"idle_frame")
	loadEquipment()


func loadRace():
	if G.race != 0:
		stats.Health = 100
		stats.HealthMax = 100
		if G.race == 1:
			get_node("player_body/Armature/Skeleton/BoneAttachment/horn").visible = true
		elif G.race == 2:
			get_node("player_body/Armature/Skeleton/WingL").visible = true
			get_node("player_body/Armature/Skeleton/WingR").visible = true
			get_node("player_body/Armature/Skeleton/BoneAttachment 6").visible = true


func loadEquipment():
	if have_coat:
		$"player_body/Armature/Skeleton/BoneAttachment/hat".visible = true
		$"player_body/Armature/Skeleton/coat".visible = true
	
	if equipment.have_armor:
		get_node("player_body/Armature/Skeleton/armor").visible = true
	if equipment.have_socks:
		var playerBodyMesh = G.player.get_node("player_body/Armature/Skeleton/Body")
		playerBodyMesh.set_surface_material(0, G.player.socks_material)
		audi.set_unit_size(0.15)
	if equipment.have_bandage:
		get_node("player_body/Armature/Skeleton/BoneAttachment/bandage").visible = true
	if equipment.have_headrope:
		get_node("player_body/Armature/Skeleton/BoneAttachment/headrope").visible = true 


func handleImpulse():
	if impulse.length() > 0:
		move_and_collide(impulse)
		impulse.x /= 1.5
		impulse.y /= 1.5
		impulse.z /= 1.5


func _physics_process(delta):
	process_input(delta)
	if stats.Health > 0 && mayMove:
		handleImpulse()
		process_movement(delta)
	else:
		vel = Vector3(0,0,0)


func _setValueZero(value, step, new_value=0, delta = 0.1):
	if(value > step + new_value):
		value -= step * delta * 20
	elif(value < -step + new_value):
		value += step * delta * 20
	else:
		value = new_value
	return value


func _clumpBody(speedX): #ограничение вращения камерой, когда игрок лежит
	if lying:
		if speedX > 0 && body.body_rot < body.MAX_ANGLE:
			return true
		if speedX < 0 && body.body_rot > -body.MAX_ANGLE:
			return true
		return false
	return true


func Faint(temp_roped = false):
	lying = true
	mayMove = false
	if temp_roped:
		stats.head.shyOn()
		roped = temp_roped
		body.playback.travel("Roped")
		get_node("player_body/Armature/Skeleton/BoneAttachment 4/rope1").visible = true
		get_node("player_body/Armature/Skeleton/BoneAttachment 5/rope-legs1").visible = true
		get_node("player_body/Armature/Skeleton/BoneAttachment 6/rope-wings").visible = true
		get_node("player_body/Armature/Skeleton/BoneAttachment 7/rope-legs2").visible = true
	else:
		body.playback.travel("Lying")


func Unrope():
	unroping = 3
	audi_hitted.stream = unroped_sound
	audi_hitted.play()
	get_node("player_body/Armature/Skeleton/BoneAttachment 4/rope1").visible = false
	get_node("player_body/Armature/Skeleton/BoneAttachment 5/rope-legs1").visible = false
	get_node("player_body/Armature/Skeleton/BoneAttachment 6/rope-wings").visible = false
	get_node("player_body/Armature/Skeleton/BoneAttachment 7/rope-legs2").visible = false
	roped = false
	body.playback.travel("Lying")


func GetUp():
	mayMove = false
	body.playback.travel("GetUp")
	yield(get_tree().create_timer(1.6),"timeout")
	if lying && !roped:
		lying = false
		mayMove = true

func _sit(sit_on):
	crouching = sit_on
	stealth.label.visible = sit_on
	if sit_on:
		body_collider_size = 0.4
		body.translation.y = 1.55
		MAX_SPEED = 8
		crouch_cooldown = 0.5
	else:
		body_collider_size = 1
		body.translation.y = 1.024
		MAX_SPEED = 17


func process_input(delta):
	# ----------------------------------
	# Teleporting (for ucinorns)
	if start_teleporting:
		OnStairs = false
		$audi_guns.stream = teleport_sound
		$audi_guns.play()
		
		var effect1 = teleport_effect.instance()
		get_parent().add_child(effect1)
		effect1.global_transform.origin = global_transform.origin
		
		global_transform.origin = temp_teleport_mark.global_transform.origin
		temp_teleport_mark.queue_free()
		stats.mana -= stats.TELEPORT_COST
		
		var effect2 = teleport_effect.instance()
		get_parent().add_child(effect2)
		effect2.global_transform.origin = global_transform.origin
		tempRay.enabled = false
		start_teleporting = false
		
		horn_particles.set_emitting(true)
		yield(get_tree().create_timer(0.25),"timeout")
		horn_particles.set_emitting(false)
	
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
	var input_movement_vector = Vector2()
	var goSide = false
	running = false
	flying_fast = false
	
	if Input.is_action_pressed("ui_up"):
		if flying:
			flying_fast = true
			
		if !crouching && Input.is_action_pressed("ui_shift") && G.race == 0:
			running = true
		
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
		sideAngle += 0.1
		goSide = true
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1
		sideAngle -= 0.1
		goSide = true
	
	#update camera walk position
	if thirdView:
		rotation_helper_third.rotation.x = rotation_helper.rotation.x
	
	rotation_helper.global_transform.origin = camera_head_pos.global_transform.origin
	
	if roped:
		if input_movement_vector.length() > 0:
			if unroping < 5:
				stats.head.shyOn()
				unroping += delta
				body.playback.travel("Unroping")
				if !audi_hitted.is_playing():
					audi_hitted.stream = unroping_sound
					audi_hitted.play()
				return
			else:
				Unrope()
				return
		else:
			body.playback.travel("Roped")
			if unroping > 0:
				unroping -= delta
			return
	
	#update camera walk rotation
	if(goSide):
		sideAngle = clamp(sideAngle,-2, 2)
	else:
		sideAngle = _setValueZero(sideAngle, 0.2, 0, delta)
	
	camera.rotation_degrees.z = sideAngle
	
	if lying && input_movement_vector.length() > 0:
		GetUp()
	
	if !OnStairs || input_movement_vector.length() > 0:
		stairGravity = 1
	else:
		stairGravity = 0

	input_movement_vector = input_movement_vector.normalized()
	
	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	
	# ----------------------------------
	# Jumping
	if is_on_floor():
		if flying:
			flying = false
			$shield/audi.stop()
		
		if G.race != 1:
			if Input.is_action_just_pressed("jump"):
				if crouching:
					body_collider_size = 1
					MAX_SPEED = 17
					body.translation.y = 1.024
					stealth.label.visible = false
					yield(get_tree().create_timer(0.1),"timeout")
					crouching = false
				else:
					OnStairs = false
					vel.y = JUMP_SPEED
		else:
			if !jump_hint.visible && stats.mana > stats.TELEPORT_COST && Input.is_action_pressed("jump"):
				if stats.Health > 0:
					tempRay = weapons.enableHeadRay(stats.TELEPORT_DISTANCE)
					if !teleport_pressed:
						teleport_pressed = true
						var wr = weakref(temp_teleport_mark)
						if !wr.get_ref():
							temp_teleport_mark = teleport_mark.instance()
							get_parent().add_child(temp_teleport_mark)
							temp_teleport_mark.global_transform.origin = global_transform.origin
							
					elif tempRay.is_colliding() && tempRay.get_collider().name != "sky":
						var wr = weakref(temp_teleport_mark) #оно может внезапно стереться даже здесь
						if wr.get_ref():
							var place = tempRay.get_collision_point()
							temp_teleport_mark.global_transform.origin = place
							
							#чтоб не перемещаться через стенки бункера наружу
							if teleport_inside && temp_teleport_mark.translation.y > translation.y + 3:
								temp_teleport_mark.translation.y -= 3
						else:
							temp_teleport_mark = teleport_mark.instance()
							get_parent().add_child(temp_teleport_mark)
				elif teleport_pressed:
					teleport_pressed = false
					var wr = weakref(temp_teleport_mark)
					if wr.get_ref():
						temp_teleport_mark.queue_free()
		
		# Crouching
		if crouch_cooldown > 0:
			crouch_cooldown -= delta
		
		var dash = false
		if G.race == 0 && Input.is_action_just_pressed("dash"):
			dash = true
		
		if Input.is_action_just_pressed("crouch") || dash:
			if crouch_cooldown <= 0 || !crouching:
				_sit(!crouching)
				
				if crouching && dash:
					vel.x *= 5
					vel.z *= 5
					stats.dashBlock()
	else:
		if !flying && mayMove:
			if G.race == 2 && Input.is_action_just_pressed("jump") && !jump_hint.visible:
				OnStairs = false
				flying = true
				$shield/audi.stream = wings_sound
				$shield/audi.play()
		else:
			if Input.is_action_pressed("jump"): #летим вверх
				speedY = 15
			elif Input.is_action_pressed("ui_shift"): #летим вниз
				speedY = -18
			else:
				if flying_fast:
					speedY = rotation_helper.rotation_degrees.x / 5
				else:
					speedY = 0
	body_collider.scale.y = _setValueZero(body_collider.scale.y, 0.1, body_collider_size, delta)
	body_collider_2.scale.y = _setValueZero(body_collider_2.scale.y, 0.1, body_collider_size, delta)
	# ----------------------------------


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	#обрабатываем тряску во время ядерного взрыва
	var temp_shake = 0
	if shaking_speed > 0:
		temp_shake = shaking_speed
		
		if !shakeUp: #меняем скорость
			temp_shake *= -1
		
		if shake_timer > 0: #ждем следующей смены скорости
			shake_timer -= delta
		else:
			shake_timer = SHAKE_TIME
			shakeUp = !shakeUp
	
	if OnStairs && stairGravity == 0:
		vel.y = 0
	elif !flying:
		vel.y += delta * GRAVITY + temp_shake
	else:
		vel.y = speedY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	if flying:
		if flying_fast:
			flySpeed += fly_increase * delta
			if fly_increase > 0:
				fly_increase -= delta * 15
		else:
			flySpeed = RUN_SPEED
			fly_increase = 20.0
		
		target *= flySpeed
		
	elif running:
		target *= RUN_SPEED
	else:
		target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		if flying:
			accel = fly_decrease
		else:
			accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _process(delta):
	if body.rotation_degrees.z != 0:
		if flying_fast:
			if body.rotation_degrees.z > 1:
				body.rotation_degrees.z -= delta * abs(body.rotation_degrees.z)
			elif body.rotation_degrees.z < -1:
				body.rotation_degrees.z += delta * abs(body.rotation_degrees.z)
			else:
				body.rotation_degrees.z = 0
		else:
			body.rotation_degrees.z = 0


func _input(event):
	if stats.Health > 0:
		if event is InputEventKey:
			if !event.pressed && teleport_pressed && !Input.is_action_pressed("jump"):
				teleport_pressed = false
				start_teleporting = true
		
		
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg2rad(event.relative.y * -MOUSE_SENSITIVITY))
			if _clumpBody(event.relative.x):
				self.rotate_y(deg2rad(event.relative.x * -MOUSE_SENSITIVITY))
			
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -65, 70) 
			camera_rot.y = 0
			camera_rot.z = sideAngle
			rotation_helper.rotation_degrees = camera_rot
			if flying_fast:
				if event.relative.x != 0:
					body.rotation_degrees.z += event.relative.x * -MOUSE_SENSITIVITY * 0.5

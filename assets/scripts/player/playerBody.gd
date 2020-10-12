extends Spatial

#скрипт анимирует тело и не дает ему поворачиваться, 
#пока угол между ним и головой не больше MAX_ANGLE

const CROUCH_COOLDOWN = 5
const JUMP_COOLDOWN = 0.6
const MAX_ANGLE = 90
var body_rot = 0
var onetime = false

onready var animTree = get_node("animTree")
onready var head = get_node("../Rotation_Helper")
onready var legsHit = get_node("../hitsManager")

var playback
var head_blend
var walk_offset = 0

var jumping_cooldown = 0
var crouching_cooldown = 0
var smile_cooldown = 5
var shy_cooldown = 1.5


func _is_walking():
	return G.player.mayMove && (Input.is_action_pressed("ui_left") || \
		Input.is_action_pressed("ui_right") || \
		Input.is_action_pressed("ui_up")  || Input.is_action_pressed("ui_down"))


func playerMakingShy():
	if get_node("Armature/Skeleton/coat").visible:
		if G.player.hitting && !legsHit.temp_front:
			if body_rot > 17 && body_rot < 44 && head_blend.y > 0.4:
				return true
		else:
			if body_rot < 61 && body_rot > 27 && head_blend.y > 1:
				return true
	return false


func _updateHeadRotation(delta):
	head_blend.y = head.rotation_degrees.x / 60 + walk_offset
	if _is_walking() || jumping_cooldown > 0:
		if G.player.flying_fast:
			if walk_offset < 0.7:
				walk_offset += 0.03
		else:
			if walk_offset < 0.3:
				walk_offset += 0.02
			elif walk_offset > 0.4:
				walk_offset -= 0.03
#	elif legsHit.hitting && legsHit.temp_front && (body_rot > 130 || body_rot < -105):
#		if walk_offset < 0.5:
#			walk_offset += 0.06
	else:
		if G.player.crouching && crouching_cooldown > 0:
			if walk_offset < 0.3:
				walk_offset += 0.02
			elif walk_offset > 0.4:
				walk_offset -= 0.03
		else:
			if walk_offset > 0.1:
				walk_offset -= 0.03
	
	var rot_x = 0
	if !G.player.body_follows_camera:
		if body_rot > 130:
			head_blend.y *= -1
			rot_x = (body_rot - 200.0) / 90.0
		elif body_rot < -105:
			head_blend.y *= -1
			rot_x = (body_rot + 159.0) / 90.0
		else:
			rot_x = body_rot / 90.0
	head_blend.x = G.setValueZero(head_blend.x, 0.12, rot_x, delta)
	animTree.set("parameters/BlendSpace2D/blend_position", head_blend)


func _ready():
	playback = animTree.get("parameters/StateMachine/playback")
	head_blend = animTree.get("parameters/BlendSpace2D/blend_position")
	playback.start("Idle1")


func _process(delta):
	#--animating body--
	if G.player.stats.Health > 0:
		_updateHeadRotation(delta)
		
		if body_rot > 130 || body_rot < -105:
			if smile_cooldown > 0:
				smile_cooldown -= delta
			else:
				smile_cooldown = 5
				G.player.stats.head.smileOn()
		else:
			if smile_cooldown != 5:
				smile_cooldown = 5
				G.player.stats.head.smileOff()
		
		if G.player.have_coat && playerMakingShy():
			if shy_cooldown > 0:
				shy_cooldown -= delta
			else:
				shy_cooldown = 1.5
				G.player.stats.head.shyOn()
		
		if jumping_cooldown > 0:
			jumping_cooldown -= delta
		
		if crouching_cooldown > 0:
			crouching_cooldown -= delta
		
		if _is_walking():
			if G.player.crouching:
				playback.travel("Crouch")
				crouching_cooldown = CROUCH_COOLDOWN
			else:
				crouching_cooldown = 0
				
				if G.player.flying:
					if G.player.flying_fast:
						playback.travel("Fly")
					else:
						if Input.is_action_pressed("ui_left"):
							playback.travel("Fly-Left")
						elif Input.is_action_pressed("ui_right"):
							playback.travel("Fly-Right")
						else:
							playback.travel("Fly-OnPlace")
				else:
					if G.race != 1 && Input.is_action_just_pressed("jump"):
						if G.player.running:
							playback.travel("Jump-Run")
						else:
							playback.travel("Jump")
						jumping_cooldown = JUMP_COOLDOWN
					
					elif jumping_cooldown <= 0:
						if G.player.running:
							playback.travel("Run")
						else:
							playback.travel("Walk")
			body_rot = 0
			onetime = true
		elif G.player.mayMove:
			if G.player.crouching:
				if !G.player.body_follows_camera && crouching_cooldown <= 0:
					playback.travel("Sit")
				else:
					playback.travel("Crouch-idle")
			else:
				crouching_cooldown = 0
				
				if G.player.flying:
					playback.travel("Fly-OnPlace")
				else:
					#проверка на расу нужна, тк единороги не прыгают вообще
					if G.race != 1 && Input.is_action_just_pressed("jump")&& !G.player.blockJump:
						playback.travel("Jump")
						jumping_cooldown = JUMP_COOLDOWN
					elif jumping_cooldown <= 0:
						playback.travel("Idle1")
				
			if onetime:
				body_rot = rotation_degrees.y
				onetime = false
		
		#--rotating body--
		if G.player.mayMove:
			if Input.is_action_pressed("ui_left") && (!G.player.flying || G.player.flying_fast):
				body_rot = 90.0
				if Input.is_action_pressed("ui_up"):
					body_rot = 45.0
				elif Input.is_action_pressed("ui_down"):
					body_rot = -45.0
			if Input.is_action_pressed("ui_right") && (!G.player.flying || G.player.flying_fast):
				body_rot = -90.0
				if Input.is_action_pressed("ui_up"):
					body_rot = -45.0
				elif Input.is_action_pressed("ui_down"):
					body_rot = 45.0
		
		if G.player.body_follows_camera:
			body_rot = 0
			rotation_degrees.y = 0
		elif G.player.vel.length() > 0 && !G.player.roped:
			var rot_y = rotation_degrees.y
			rotation_degrees.y = G.setValueZero(rot_y, 16, body_rot, delta)
		else:
			rotation_degrees.y = body_rot
			if body_rot < -180:
				body_rot = 180
			if body_rot > 180:
				body_rot = -180
	else:
		body_rot = 0
		playback.travel("Die1")


func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_sens = G.player.MOUSE_SENSITIVITY
		var speed_x = clamp(event.relative.x,-450,450) * -mouse_sens
		if (G.player.thirdView && !G.player.weapons.gunOn && !G.player.lying) || \
		(event.relative.x < 0 && body_rot > -MAX_ANGLE) || \
		(event.relative.x > 0 && body_rot < MAX_ANGLE):
			body_rot -= speed_x

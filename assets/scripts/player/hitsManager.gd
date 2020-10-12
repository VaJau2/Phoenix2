extends Node

const EARTHPONY_FRONT_DAMAGE = 40
const EARTHPONY_BACK_DAMAGE = 80

const FRONT_DAMAGE = 10
const BACK_DAMAGE = 25

var tryHit = preload("res://assets/audio/enemies/SwordTryHit.wav")
var hit = preload("res://assets/audio/flying/PegasusHit.wav")
var material_sounds = {
	"door": preload("res://assets/audio/guns/legHits/door_slam.wav"),
	"door_open": preload("res://assets/audio/guns/legHits/door_slam_open.wav"),
	"fence": preload("res://assets/audio/guns/legHits/fence_hit.wav"),
	"stone": preload("res://assets/audio/guns/legHits/stone_hit.wav"),
	"wood": preload("res://assets/audio/guns/legHits/wood_hit.wav")
}

onready var player = get_parent()
onready var audi = get_node("../audi_hitted")

var temp_front = false
var stopping_hit = false
var hitting_timer = 0

var front_objects = []
var back_objects = []


func handleVictim(victim, damage):
	if victim != null:
		if victim is Character:
			audi.stream = hit
			victim.TakeDamage(damage)
		else:
			var material = victim.physics_material_override as NamedPhysicsMaterial
			if material && material.name in material_sounds:
				audi.stream = material_sounds[material.name]
			else:
				audi.stream = material_sounds["stone"]
		
			if "fence" in victim.name:
				audi.stream = material_sounds["fence"]
			elif "broken" in victim:
				victim.brake(damage)
			elif "door" in victim.name && !victim.open:
				if !victim.force_opening:
					victim.get_node("audi").stream = material_sounds.stone
					victim.get_node("audi").play()
				
				elif (victim.my_key != "" && G.race != 0):
					victim.get_node("audi").stream = material_sounds.door
					victim.get_node("audi").play()
				
				else:
					victim._open(material_sounds.door_open, 0, true)


func start_hit(front):
	temp_front = front
	player.hitting = true
	player.mayMove = false
	if front:
		player.body_follows_camera = true
		player.body.playback.travel("HitFront-1")
	else:
		player.body.playback.travel("HitBack-1")


func finish_hit():
	stopping_hit = true
	if temp_front:
		if player.weapons._isPistol():
			player.body_follows_camera = false
		
		player.body.playback.travel("HitFront-2")
	else:
		player.body.playback.travel("HitBack-2")
	yield(get_tree().create_timer(0.15),"timeout")
	audi.stream = tryHit
	audi.play()
	yield(get_tree().create_timer(0.1),"timeout")
	audi.stream = null
	
	if temp_front:
		var damage = FRONT_DAMAGE
		if G.race == 0:
			damage = EARTHPONY_FRONT_DAMAGE
		damage *= hitting_timer
		for victim in front_objects:
			handleVictim(victim, damage)
	else:
		var damage = BACK_DAMAGE
		if G.race == 0:
			damage = EARTHPONY_BACK_DAMAGE
		damage *= hitting_timer
		for victim in back_objects:
			handleVictim(victim, damage)
	audi.play()
	
	yield(get_tree().create_timer(0.5),"timeout")
	player.hitting = false
	player.mayMove = true
	stopping_hit = false


func _process(delta):
	if !player.hitting && player.stats.Health > 0 && player.mayMove && !player.running && !player.flying:
		if Input.is_action_just_pressed("legsHit") && player.is_on_floor():
			hitting_timer = 0
			var front_hit = abs(player.body.body_rot) < 60
			start_hit(front_hit)
	if player.hitting:
		if hitting_timer < 5:
			hitting_timer += delta
		
		if !stopping_hit:
			if Input.is_action_just_released("legsHit"):
				finish_hit()


func _on_frontarea_body_entered(body):
	if body is StaticBody || body is Character:
		front_objects.append(body)


func _on_frontarea_body_exited(body):
	if body in front_objects:
		front_objects.erase(body)


func _on_backarea_body_entered(body):
	if body is StaticBody || body is Character:
		back_objects.append(body)


func _on_backarea_body_exited(body):
	if body in back_objects:
		back_objects.erase(body)

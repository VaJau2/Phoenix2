extends Character

#Ходячие неписи должны находиться в своем отдельном ноде
# иначе они все идут дружно в одну точку, хз почему

const WAIT_TIME = 1

var start_pos
var start_rot
var brake_sound2 = preload("res://assets/audio/guns/result/mrHandy_break-2.wav")

var patrol_points = []
var pointI = 0
var waitTimer = 0

var state = 0
var seePlayer = false
var player_last_pos = Vector3(0,0,0)
var timer_seek_player = 2

onready var step_audi = get_node("audi")
onready var seekArea = get_node("../../props/buildings/stealth/passArea")
onready var lamp = get_node("corpus/monitor/lamp")
onready var screen = get_node("corpus/monitor/screen")
var materials = {
	"green": null,
	"orange": preload("res://assets/materials/enemies/robots/roboEyeUnshaded-Orange.tres"),
	"red": preload("res://assets/materials/enemies/robots/roboEyeUnshaded-Red.tres"),
	"dead": preload("res://assets/materials/enemies/robots/roboEye-dead.tres")
}


func _ready():
	scores = 60
	active = false
	start_pos = global_transform.origin
	start_rot = rotation
	patrol_points = [get_node("../../props/buildings/stealth/patrol_points/" + name)]
	patrol_points += patrol_points[0].get_children()
	materials.green = lamp.get_surface_material(0)
	set_collision_layer(0)
	set_collision_mask(0)
	vel = Vector3(0,0,0)


func set_state(new_state: String):
	if Health > 0 && active:
		if new_state == "idle":
			state = 0
			G.player.stealth.removeSeekEnemy(self)
			G.player.stealth.removeAttackEnemy(self)
			lamp.set_surface_material(0, materials.green)
		
		elif new_state == "attack":
			state = 1
			timer_seek_player = 0
			seePlayer = true
			G.player.stealth.addAttackEnemy(self)
			lamp.set_surface_material(0, materials.red)
			seekArea.loseTraining()
			yield(get_tree().create_timer(0.5),"timeout")
			G.player.stealth.removeAttackEnemy(self)
			G.player.stealth.removeSeekEnemy(self)
			
		elif new_state == "seek":
			G.player.stealth.addSeekEnemy(self)
			seePlayer = false
			state = 2
			lamp.set_surface_material(0, materials.orange)
		else:
			print("what is " + new_state + "?")



func TakeDamage(damage: int, shapeID = 0):
	Health -= 1
	if Health > 0:
		audi.play()
	else:
		if step_audi.is_playing():
			step_audi.stop()
		
		if state == 0:
			scores = scores * 2
		seekArea.decreseRoboEyesCount(scores)
		
		if state != 0:
			G.player.stealth.removeAttackEnemy(self)
			G.player.stealth.removeSeekEnemy(self)
		
		lamp.set_surface_material(0, materials.dead)
		screen.set_surface_material(0, materials.dead)
		audi.stream = brake_sound2
		audi.play()
		anim.play("Die")
		set_collision_layer(0)
		set_collision_mask(0)
		vel = Vector3(0,0,0)


func Reset():
	scores = 60
	set_collision_layer(1)
	set_collision_mask(1)
	global_transform.origin = start_pos
	rotation = start_rot
	Health = 2
	pointI = 0
	
	lamp.set_surface_material(0, materials.green)
	screen.set_surface_material(0, materials.green)
	set_state("idle")


func _stop():
	anim.play("idle")
	vel = Vector3(0,0,0)


func _patrol(delta):
	if waitTimer > 0:
		waitTimer -= delta
		_stop()
		if step_audi.is_playing():
			step_audi.stop()
	else:
		if !close_to_point:
			moveTo(patrol_points[pointI].global_transform.origin, 1.5)
			anim.play("walk")
			if !step_audi.is_playing():
				step_audi.play()
		else:
			waitTimer = WAIT_TIME
			
			if pointI < patrol_points.size() - 1:
				pointI += 1
			else:
				pointI = 0
			
			close_to_point = false


func _process(delta):
	if Health > 0:
		if !active:
			if vel.length() > 0:
				_stop()
			return
		
		if scores > 10:
			scores -= delta
		match state:
			0: #--idle
				_patrol(delta)
			
			1: #--attack
				var player_pos = G.player.global_transform.origin
				player_pos.y = global_transform.origin.y
				look_at(player_pos, Vector3.UP)
				_stop()
				if step_audi.is_playing():
					step_audi.stop()
			
			2: #--seek
				var player_pos = G.player.global_transform.origin
				player_pos.y = global_transform.origin.y
				look_at(player_pos, Vector3.UP)
				_stop()
				if step_audi.is_playing():
					step_audi.stop()
				
				if timer_seek_player > 0:
					timer_seek_player -= delta
				else:
					timer_seek_player = 2
					set_state("idle")

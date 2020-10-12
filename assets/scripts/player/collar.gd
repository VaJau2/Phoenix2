extends MeshInstance

const FAR_TIME = 4
const SPEED = 5

onready var slider = get_node("/root/Main/canvas/collar_distance")

var pipSound = preload("res://assets/audio/enemies/slave_traders/collarPIP.wav")
var explosion = preload("res://assets/audio/enemies/slave_traders/explosion.wav")
onready var audi = get_node("/root/Main/Player/audi_hitted")

var head
var headParts = preload("res://objects/npc/meat/headExplosion.tscn")

onready var enemies = get_node("/root/Main/enemies")
var angry_onetime = false

var far_away = false
var far_away_timer = 0
var pip_timer = 0

func setHeadBack():
	head.visible = true
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment").visible = true


func _explode():
	audi.stream = explosion
	audi.play()
	head = G.player.get_node("player_body/Armature/Skeleton/Head")
	head.visible = false
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment").visible = false
	
	var tempParts = headParts.instance()
	get_node("/root/Main/").add_child(tempParts)
	tempParts.global_transform.origin = head.global_transform.origin
	
	G.player.stats.TakeDamage(200, Vector3.ZERO, true)
	G.player.stats.headless = true
	slider.set_visible(false)
	
	if !angry_onetime:
		enemies.MakeEveryoneAngry()
		angry_onetime = true
	
	set_process(false)


func _ready():
	if slider:
		slider.set_max(FAR_TIME)


func _process(delta):
	if visible:
		if !G.player.mayMove:
			return
		
		if G.player.stats.Health <= 0:
			visible = false
		if !slider.is_visible():
			slider.set_visible(true)
		
		
		if far_away_timer == 0:
			slider.modulate.g = 1
			slider.modulate.r = 0
		else:
			slider.modulate.g = FAR_TIME/far_away_timer
			slider.modulate.r = far_away_timer/FAR_TIME
		slider.value = far_away_timer
				
		if far_away:
			if far_away_timer < FAR_TIME:
				far_away_timer += delta * SPEED
				
				if pip_timer < 1:
					pip_timer += delta * far_away_timer
				else:
					pip_timer = 0
					audi.stream = pipSound
					audi.play()
			else:
				_explode()
		else:
			if far_away_timer > 0:
				far_away_timer -= delta * SPEED
	else:
		if slider:
			if slider.is_visible():
				slider.set_visible(false)
				visible = false
		else:
			set_process(false)

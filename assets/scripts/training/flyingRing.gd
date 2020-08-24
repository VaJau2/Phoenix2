extends Area

export var nextRingPath: NodePath
export var timer = 8
export var increase = true
var temp_timer
var nextRing
var working = false

onready var passArea = get_node("../../passArea")


func start():
	set_process(true)
	$sprite.modulate.a = 1
	visible = true
	working = true
	temp_timer = timer
	nextRing = get_node(nextRingPath)
	if nextRing:
		nextRing.visible = true
		nextRing.get_node("sprite").modulate.a = 0.5


func _ready():
	set_process(false)

func _process(delta):
	if working:
		if temp_timer > 0:
			temp_timer -= delta
			if temp_timer < 1:
				$sprite.modulate.a = temp_timer
		else:
			set_process(false)
			visible = false
			working = false
			if nextRing:
				nextRing.visible = false
			if increase:
				passArea.loseTraining()
			else:
				passArea.is_training = false


func _on_flyingRing_body_entered(body):
	if visible && body.name == "Player":
		set_process(false)
		if working:
			visible = false
			working = false
			if increase:
				passArea.increase += temp_timer
			G.player.get_node("audi_hitted").stream = passArea.ringFly1
			G.player.get_node("audi_hitted").play()
			if nextRing != null:
				nextRing.start()
			else:
				passArea.finishTraining()
		else:
			passArea.loseTraining()
			visible = false
			working = false
			if nextRing:
				nextRing.visible = false

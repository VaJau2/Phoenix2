extends MeshInstance

onready var slider = get_node("/root/Main/canvas/collar_distance")
var my_owner = null

var pipSound = preload("res://assets/audio/enemies/slave_traders/collarPIP.wav")
var explosion = preload("res://assets/audio/enemies/slave_traders/explosion.wav")
onready var audi = get_node("/root/Main/Player/audi_hitted")

var head
var headParts = preload("res://objects/enemies/meat/headExplosion.tscn")

var pipTimer = 5

func setHeadBack():
	head.visible = true
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment").visible = true
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment 2").visible = true


func _process(delta):
	var wr = weakref(my_owner)
	if visible && my_owner != null && wr.get_ref():
		if !G.player.mayMove:
			return
		
		if G.player.stats.Health <= 0:
			visible = false
		if !slider.is_visible():
			slider.set_visible(true)
		var owner_pos = my_owner.global_transform.origin
		var temp_dist = global_transform.origin.distance_to(owner_pos)
		
		slider.modulate.r = temp_dist/50
		slider.modulate.g = 50/temp_dist
		slider.value = temp_dist
		
		if temp_dist >= 60:
			audi.stream = explosion
			audi.play()
			head = G.player.get_node("player_body/Armature/Skeleton/Head")
			head.visible = false
			G.player.get_node("player_body/Armature/Skeleton/BoneAttachment").visible = false
			G.player.get_node("player_body/Armature/Skeleton/BoneAttachment 2").visible = false
			
			var tempParts = headParts.instance()
			get_node("/root/Main/").add_child(tempParts)
			tempParts.global_transform.origin = head.global_transform.origin
			
			G.player.stats.TakeDamage(200, Vector3.ZERO)
			G.player.stats.headless = true
			slider.set_visible(false)
			set_process(false)
		elif temp_dist > 18:
			if pipTimer > 0:
				pipTimer -= delta * temp_dist
			else:
				pipTimer = 12
				audi.stream = pipSound
				audi.play()
		
	else:
		if slider:
			if slider.is_visible():
				slider.set_visible(false)
				visible = false
		else:
			set_process(false)

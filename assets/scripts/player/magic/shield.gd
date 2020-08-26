extends Spatial

onready var stats = get_node("../stats")
onready var light = get_node("../lightsCheck")

onready var first = get_node("first")
onready var third = get_node("third")

onready var hornParticles = get_node("../player_body/Armature/Skeleton/BoneAttachment/horn/Particles")

var material
var play_onetime = false

func _ready():
	material = first.get_surface_material(0)


func _process(delta):
	if G.race == 1:
		first.visible = false
		third.visible = false
		if Input.is_action_pressed("ui_shift"):
			if stats.mana > stats.SHIELD_COST:
				first.visible = true
				third.visible = true
				hornParticles.set_emitting(true)
				stats.mana -= stats.SHIELD_COST * delta
		
		if first.visible:
			var color = material.get_albedo()
			color.a = stats.mana / 1500
			material.set_albedo(color)
			first.set_surface_material(0, material)
			third.set_surface_material(0, material)
			light.on_light = true
			if !play_onetime:
				$audi.play()
				play_onetime = true
		else:
			if play_onetime:
				light._checkOff()
				$audi.stop()
				hornParticles.set_emitting(false)
				play_onetime = false

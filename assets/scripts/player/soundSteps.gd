extends Node

const STEP_COOLDOWN = 0.4
const STEP_CROUCH_COOLDOWN = 0.8
const STEP_RUN_COOLDOWN = 0.6

export var check_vertical_moves = true

onready var ray = get_node("RayCast")
onready var player = get_node("../")

var timer = 0
var i = 0

var land_material = "grass"

var dash = preload("res://assets/audio/steps/dash.wav")
var jump = preload("res://assets/audio/steps/jump.wav")

var steps = {
	"grass": [
		preload("res://assets/audio/steps/grass/stepGrassFast1.wav"),
		preload("res://assets/audio/steps/grass/stepGrassFast2.wav"),
		preload("res://assets/audio/steps/grass/stepGrassFast3.wav")
	],
	"dirt": [
		preload("res://assets/audio/steps/dirt/stepDirtFast1.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtFast2.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtFast3.wav")
	],
	"wood": [
		preload("res://assets/audio/steps/wood/stepWoodFast1.wav"),
		preload("res://assets/audio/steps/wood/stepWoodFast2.wav"),
		preload("res://assets/audio/steps/wood/stepWoodFast3.wav")
	],
	"stone": [
		preload("res://assets/audio/steps/stone/StoneStep1.wav"),
		preload("res://assets/audio/steps/stone/StoneStep2.wav"),
		preload("res://assets/audio/steps/stone/StoneStep3.wav")
	],
}

var stepsRun = {
	"grass": [
		preload("res://assets/audio/steps/grass/stepGrassRun1.wav"),
		preload("res://assets/audio/steps/grass/stepGrassRun2.wav"),
		preload("res://assets/audio/steps/grass/stepGrassRun3.wav")
	],
	"dirt": [
		preload("res://assets/audio/steps/dirt/stepDirtRun1.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtRun2.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtRun3.wav")
	],
	"wood": [
		preload("res://assets/audio/steps/dirt/stepDirtRun1.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtRun2.wav"),
		preload("res://assets/audio/steps/dirt/stepDirtRun3.wav")
	],
	"stone": [
		preload("res://assets/audio/steps/stone/StoneStepRun1.wav"),
		preload("res://assets/audio/steps/stone/StoneStepRun2.wav"),
		preload("res://assets/audio/steps/stone/StoneStepRun3.wav")
	],
}

var stepsCrouch = {
	"grass": [
		preload("res://assets/audio/steps/grass/stepGrass1.wav"),
		preload("res://assets/audio/steps/grass/stepGrass2.wav"),
		preload("res://assets/audio/steps/grass/stepGrass3.wav")
	],
	"dirt": [
		preload("res://assets/audio/steps/dirt/stepDirt1.wav"),
		preload("res://assets/audio/steps/dirt/stepDirt2.wav"),
		preload("res://assets/audio/steps/dirt/stepDirt3.wav")
	],
	"wood": [
		preload("res://assets/audio/steps/wood/stepWoodFast1.wav"),
		preload("res://assets/audio/steps/wood/stepWoodFast2.wav"),
		preload("res://assets/audio/steps/wood/stepWoodFast3.wav")
	],
	"stone": [
		preload("res://assets/audio/steps/stone/StoneStep1.wav"),
		preload("res://assets/audio/steps/stone/StoneStep2.wav"),
		preload("res://assets/audio/steps/stone/StoneStep3.wav")
	],
}

func _process(delta):
		if check_vertical_moves:
			if Input.is_action_just_pressed("jump") && !player.flying && G.race != 1:
				player.audi.stream = jump
				player.audi.play()
				timer = 0
		
			if player.crouching && Input.is_action_just_pressed("dash") && \
			player.vel.length() > 10 && player.crouch_cooldown > 0.2 &&\
			G.race == 0:
				if player.audi.stream != dash:
					player.audi.stream = dash
					player.audi.play()
					timer = STEP_COOLDOWN
		
		if player.vel.length() > 6 && (player.is_on_floor() || !check_vertical_moves):
			if timer > 0:
				timer -= delta
			else:
				if check_vertical_moves && player.crouching:
					player.audi.stream = stepsCrouch[land_material][i]
					timer = STEP_CROUCH_COOLDOWN
				else:
					if player.running:
						player.audi.stream = stepsRun[land_material][i]
						timer = STEP_RUN_COOLDOWN
					else:
						player.audi.stream = steps[land_material][i]
						timer = STEP_COOLDOWN
				player.audi.play()
				
				var oldI = i
				i = randi() % 3
				while oldI == i:
					i = randi() % 3


func _physics_process(delta):
	if player.vel.length() > 2 && (player.is_on_floor() || !check_vertical_moves):
		var collide_obj = ray.get_collider()
		if collide_obj is StaticBody:
			var material = collide_obj.physics_material_override as NamedPhysicsMaterial
			if material:
				if material.name == "stairs":
					if check_vertical_moves:
						player.OnStairs = true
					land_material = "stone"
					return
				elif check_vertical_moves && player.OnStairs:
					player.OnStairs = false
				
				if material.name == "blood":
					land_material = "wood"
				else:
					land_material = material.name
			
			elif check_vertical_moves && player.OnStairs:
					player.OnStairs = false

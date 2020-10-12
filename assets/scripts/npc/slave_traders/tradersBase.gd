extends "../zebra_base.gd"

const TIME_GET_WEAPON = 7
const TIME_ATTACK = 4
const SHOOT_CHANCE = 0.9
const WALK_SHOOT_CHANCE = 0.5

onready var prisonDoor = get_node("../../props/land/buildings/stealth/bars-door")
var aggressive = false
var collar_key = false


func becomeAggressive():
	if !aggressive:
		for trader in other_zebras:
			if trader.Health > 0 && trader.anim.current_animation != "Sleep":
				trader.aggressive = true
		
		aggressive = true
		active = true
		set_state("attack")


func seeAllyEvent(ally):
	if aggressive && !ally.aggressive:
		ally.aggressive = true


func closePrison():
	active = false
	aggressive = false
	cameToPlace = false
	
	while(!cameToPlace && Health > 0 && !aggressive):
		if !G.paused:
			goTo(prisonDoor.global_transform.origin, false)
		yield(get_tree(),"idle_frame")
	
	if Health > 0 && !aggressive:
		if prisonDoor.open:
			prisonDoor.clickFurn("key_all")
		prisonDoor.my_key = "prison_key"
	
	active = true

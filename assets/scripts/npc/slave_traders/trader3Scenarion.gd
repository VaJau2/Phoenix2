extends Scenario

onready var parent = get_parent()
onready var toiletPos = get_node("../../../props/bunker/toilet/trader3Pos")
onready var stairPoint = get_node("../../../props/land/buildings/stealth/trader_stair")

var newDialogueId = 2
var lastDialoguePath = null
var playerHere = false
var checkPlayerComing = false

var startPosition
var startRotation

func _ready():
	startPosition = parent.global_transform.origin
	startRotation = parent.global_transform.basis.get_euler()


func _changeTraderPos(newPosition, newRotation):
	parent.IdleAnim = "Idle"
	parent.cameToPlace = false
	parent.my_start_pos = newPosition
	parent.my_start_rot = newRotation


func _startLosing():
	checkPlayerComing = false
	var toiletDoor = get_node("../../../props/bunker/doors/stable-door3")
	if toiletDoor.open:
		toiletDoor.clickFurn("key_all")
	if toiletDoor.opening:
		yield(get_tree().create_timer(2),"timeout")
	
	var lang = "ru/"
	if G.english:
		lang = "en/"
	var losing_dialogue_path = "res://assets/dialogues/json/" + lang + "slaveTraders/trader3/losing.json"
	G.player.camera.dialogueMenu.startDialogue(losing_dialogue_path, parent)


func changeDialogueStage(newStage):
	.changeDialogueStage(newStage)
	match newStage:
		0:
			_changeTraderPos(stairPoint.global_transform.origin, Vector3.LEFT)
			yield(parent,"isCame")
			parent.cameToPlace = false
			_changeTraderPos(startPosition, startRotation)
			parent.IdleAnim = "Sit"
		1:
			parent.dialogue_path = "slaveTraders/trader3/meet" + str(newDialogueId) + ".json"
			newDialogueId += 1
			parent.loadDialogueLang()
			yield(get_tree().create_timer(1),"timeout")
			parent.isTalking = true
			stage = 0
		2:
			var newPosition = toiletPos.global_transform.origin
			var newRotation = toiletPos.global_transform.basis.get_euler()
			_changeTraderPos(newPosition, newRotation)
			yield(parent,"isCame")
			if playerHere:
				_startLosing()
			else:
				checkPlayerComing = true
		3:
			parent.TakeDamage(100)


func _on_playerHere_body_entered(body):
	if body.name == "Player":
		playerHere = true
		if checkPlayerComing:
			checkPlayerComing = false
			_startLosing()


func _on_playerHere_body_exited(body):
	if body.name == "Player":
		playerHere = false

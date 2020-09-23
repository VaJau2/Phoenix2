extends Node

var stage = 0
#0 - вас не видят
#1 - внимание
#2 - опасность

onready var label = get_node("/root/Main/canvas/stealthLabel")

var seekEnemies = []
var attackEnemies = []

func _checkEmpty():
	if attackEnemies.size() == 0:
		if seekEnemies.size() == 0:
			if G.english:
				label.text = "[Safe]"
			else:
				label.text = "[Вас не видят]"
			label.modulate = Color.white
			stage = 0
		else:
			if G.english:
				label.text = "[Attention]"
			else:
				label.text = "[Внимание]"
			label.modulate = Color.orange
			stage = 1
	
	for enemy in seekEnemies:
		var wr = weakref(enemy)
		if !wr.get_ref():
			seekEnemies.erase(enemy)
	
	for enemy in attackEnemies:
		var wr = weakref(enemy)
		if !wr.get_ref():
			seekEnemies.erase(enemy)


func addSeekEnemy(enemy):
	removeAttackEnemy(enemy)
	if !enemy in seekEnemies:
		seekEnemies.append(enemy)
		if attackEnemies.size() == 0:
			if G.english:
				label.text = "[Attention]"
			else:
				label.text = "[Внимание]"
			label.modulate = Color.orange
			stage = 1


func removeSeekEnemy(enemy):
	_checkEmpty()
	if enemy in seekEnemies:
		seekEnemies.erase(enemy)
		if seekEnemies.size() == 0 && attackEnemies.size() == 0:
			if G.english:
				label.text = "[Safe]"
			else:
				label.text = "[Вас не видят]"
			label.modulate = Color.white
			stage = 0


func addAttackEnemy(enemy):
	_checkEmpty()
	if !enemy in attackEnemies:
		attackEnemies.append(enemy)
		if G.english:
			label.text = "[Danger]"
		else:
			label.text = "[Опасность]"
		label.modulate = Color.red
		stage = 2


func removeAttackEnemy(enemy):
	_checkEmpty()
	if enemy in attackEnemies:
		attackEnemies.erase(enemy)
		if seekEnemies.size() == 0 && attackEnemies.size() == 0:
			if G.english:
				label.text = "[Safe]"
			else:
				label.text = "[Вас не видят]"
			label.modulate = Color.white
			stage = 0

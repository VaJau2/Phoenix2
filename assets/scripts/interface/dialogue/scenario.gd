extends Node
class_name Scenario

#общий класс для всех сценарных скриптов для НПЦ
#все они должны находиться внутри соответствующего НПЦ

var stage = 0

func changeDialogueStage(newStage):
	stage = newStage

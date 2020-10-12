#Скрипт, который управляет сообщениями, появляющимися слева-снизу
#Сообщения появляются по списку, постепенно теряют прозрачность
#Когда прозрачность достигает нуля, они пропадают
extends VBoxContainer

const HINT_TIMER = 3
export var tempTheme: Theme

var current_task = ["?","?"]
var lang = 0

#типа корутина
func waitAndDissapear(label, timer):
	#ждем таймер
	yield(get_tree().create_timer(timer), "timeout")
	#создаем переменную
	var tempA = label.get_color("font_color").a
	#пока текст цветной, убираем его
	while tempA > 0:
		label.add_color_override("font_color", Color(1,1,1,tempA - 0.1))
		tempA = label.get_color("font_color").a
		yield(get_tree().create_timer(0.05), "timeout")
	label.queue_free()


func ShowMessage(text, timer = HINT_TIMER):
	var temp_label = Label.new()
	temp_label.autowrap = true
	temp_label.text = text
	temp_label.theme = tempTheme
	temp_label.align = 2
	self.add_child(temp_label)
	waitAndDissapear(temp_label, timer)


func _ready():
	if G.english:
		lang = 1


func _input(event):
	if Input.is_action_just_pressed("task"):
		var start_phrase = "Tasks: \n" if G.english else "Задачи: \n"
		ShowMessage(start_phrase + current_task[lang])

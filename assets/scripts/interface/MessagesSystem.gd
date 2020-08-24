#Скрипт, который управляет сообщениями, появляющимися слева-снизу
#Сообщения появляются по списку, постепенно теряют прозрачность
#Когда прозрачность достигает нуля, они пропадают
extends VBoxContainer

export var tempTheme: Theme

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


func ShowMessage(text, timer):
	var temp_label = Label.new()
	temp_label.text = text
	temp_label.theme = tempTheme
	temp_label.align = 2
	self.add_child(temp_label)
	waitAndDissapear(temp_label, timer)

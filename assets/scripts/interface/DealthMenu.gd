extends "MenuBase.gd"

export var path: String


var menu_text_eng = [
	"/Phoenix2/Dealth_screen",
	"               [Again]",
	"               [To main menu]"
]


func _change_interface_language():
	$page_label.text = menu_text_eng[0]
	$again.text = menu_text_eng[1]
	$exit.text = menu_text_eng[2]


func _ready():
	if G.english:
		_change_interface_language()


func _on_again_pressed():
	$audi.play()
	updating_down_label = false
	G.game_over = false
	G.setPause(self, false)
	G.goto_scene(path, true)


func _on_exit_pressed():
	$audi.play()
	yield(get_tree().create_timer(0.2),"timeout")
	G.game_over = false
	G.goto_scene("MainMenu")

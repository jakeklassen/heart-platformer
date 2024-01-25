extends CenterContainer

@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	LevelTransition.fade_from_black()
	menu_button.grab_focus()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start_menu.tscn")

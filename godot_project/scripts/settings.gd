extends Node2D

@onready var done_button : Button = %doneButton

func _ready():
	if Input.get_connected_joypads().size() > 0:
		done_button.grab_focus()

func _process(_delta):
	pass

func return_to_main_menu():
	"""Close the settings screen and return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_done_button_pressed():
	return_to_main_menu()

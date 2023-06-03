extends Node2D

@onready var back_button = %backButton
@onready var blip = $blip

func _ready():
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()

func _process(_delta):
	pass

func go_back_to_main_menu():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_button_pressed():
	blip.play()
	await blip.finished
	go_back_to_main_menu()

extends Node2D

@onready var exit_button : Button = %ExitButton
@onready var play_button = $menuContainer/optionsContainer/buttonsContainer/PlayButton

func _ready():
	# Disable exit button if we are on the web
	if OS.get_name() == "Web":
		exit_button.hide()
	if Input.get_connected_joypads().size() > 0:
		play_button.grab_focus()

func _process(_delta):
	pass

func show_settings():
	"""Show the settings screen"""
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func show_credits():
	"""Show the credits screen"""
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_settings_button_pressed():
	"""Show the settings menu"""
	show_settings()

func exit_game():
	""""Exit to OS"""
	get_tree().quit()

func _on_credits_button_pressed():
	show_credits()

func _on_exit_button_pressed():
	exit_game()

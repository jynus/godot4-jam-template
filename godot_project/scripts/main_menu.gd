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

func exit_game():
	get_tree().quit()


func _on_exit_button_pressed():
	exit_game()

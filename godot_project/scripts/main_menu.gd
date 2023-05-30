extends Node2D

@onready var exit_button : Button = %ExitButton

func _ready():
	# Disable exit button if we are on the web
	if OS.get_name() == "Web":
		exit_button.hide()

func _process(delta):
	pass

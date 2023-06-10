extends Control

var paused : bool = false
var on_pause_menu : bool = false
@onready var settings = $settings
@onready var return_button = %returnButton
@onready var blip : AudioStreamPlayer = $blip
var previous_music : String
var previous_music_offset : float = 0

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if paused:
			if on_pause_menu:
				unpause_game()
			else:
				hide_settings()
		else:
			pause_game()

func _ready():
	visible = false


func _on_return_button_pressed():
	blip.play()
	unpause_game()

func hide_settings():
	blip.play()
	settings.visible = false
	on_pause_menu = true

func _on_settings_button_pressed():
	show_settings()

func show_settings():
	blip.play()
	settings.visible = true
	on_pause_menu = false

func _on_main_menu_button_pressed():
	blip.play()
	await blip.finished
	unpause_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func pause_game():
	previous_music = BackgroundMusic.current_song
	previous_music_offset = BackgroundMusic.stop()
	if Input.get_connected_joypads().size() > 0:
		return_button.grab_focus()
	get_tree().paused = true
	paused = true
	visible = true
	BackgroundMusic.play_song("pause")
	

func unpause_game():
	visible = false
	paused = false
	get_tree().paused = false
	BackgroundMusic.play_song(previous_music, previous_music_offset)

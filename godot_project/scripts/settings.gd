class_name UserSettings extends Node2D

@onready var done_button : Button = %doneButton
@onready var full_screen_checkbox : CheckBox = %fullScreenCheckbox
@onready var music_volume = %musicVolume
@onready var sfx_volume = %sfxVolume
@onready var test_sfx_player = %testSfxPlayer
@onready var language_option = %LanguageOption
@onready var blip = $blip

var SETTINGS_FILE_PATH : String = "user://settings.cfg"
var _configFile : ConfigFile

var music_bus_index = AudioServer.get_bus_index("music")
var sfx_bus_index = AudioServer.get_bus_index("sfx")

func _init():
	"""Constructor"""
	_configFile = ConfigFile.new()
	var err = _configFile.load(SETTINGS_FILE_PATH)
	if err != OK: 
		print("Error while loading config file: " + str(err))

func _ready():
	"""Used when first loaded on a scene"""
	if Input.get_connected_joypads().size() > 0:
		done_button.grab_focus()
	# Set ui defaults
	full_screen_checkbox.set_pressed_no_signal(
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	music_volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music_bus_index)))
	sfx_volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index)))
	language_option.select(1 if TranslationServer.get_locale().begins_with("es") else 0)

func load_settings():
	"""Load settings from config file and apply them"""
	var err = _configFile.load(SETTINGS_FILE_PATH)
	if err != OK: 
		print("Error while loading config file: " + str(err))
	# apply settings
	var window_mode = _configFile.get_value("settings", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	set_window_mode(window_mode)
	var music_volume_config = _configFile.get_value("settings", "music_volume", 0.6)
	set_volume("music", music_volume_config)
	var sfx_volume_config = _configFile.get_value("settings", "sfx_volume", 0.6)
	set_volume("sfx", sfx_volume_config)
	
	var default_language = "es" if TranslationServer.get_locale().begins_with("es") else "en"
	var language_config = _configFile.get_value("settings", "language", default_language)
	set_language(language_config)

func _process(_delta):
	pass

func return_to_main_menu():
	"""Close the settings screen and return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func set_window_mode(custom_window_mode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(custom_window_mode)

func set_config(key: String, value):
	_configFile.set_value("settings", key, value)
	_configFile.save(SETTINGS_FILE_PATH)

func apply_fullscreen(fullscreen : bool):
	var window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	set_window_mode(window_mode)
	set_config("window_mode", window_mode)

func _on_done_button_pressed():
	blip.play()
	await blip.finished
	return_to_main_menu()

func _on_full_screen_checkbox_toggled(button_pressed):
	blip.play()
	apply_fullscreen(button_pressed)

func set_volume(bus_name: String, value: float):
	var volume_db = linear_to_db(value)
	match bus_name:
		"music":
			AudioServer.set_bus_volume_db(music_bus_index, volume_db)
		"sfx":
			AudioServer.set_bus_volume_db(sfx_bus_index, volume_db)
		_:
			return

func apply_volume(bus_name: String, value: float):
	set_volume(bus_name, value)
	set_config(bus_name + "_volume", value)

func _on_music_volume_value_changed(value):
	apply_volume("music", value)

func _on_sfx_volume_value_changed(value):
	apply_volume("sfx", value)
	test_sfx_player.play()

func set_language(lang: String):
	TranslationServer.set_locale(lang)

func apply_language(lang: String):
	set_language(lang)
	if lang == "en":
		language_option.select(0)
	else:
		language_option.select(1)
	set_config("language", lang)


func _on_language_option_item_selected(index):
	if index == 0:
		print("Setting language to English")
		apply_language("en")
	else:
		print("Setting language to Spanish")
		apply_language("es")

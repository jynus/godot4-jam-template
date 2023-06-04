extends Node2D

@onready var back_button := %backButton
@onready var blip := $blip
@onready var load_level_button : PackedScene = preload("res://scene_objects/level_button.tscn")
@onready var levels_container := %levelsContainer
@onready var next_world_button := %nextWorldButton
@onready var previous_world_button := %previousWorldButton
@onready var subtitle_world := %subtitle_world


const levels_path : String = "res://levels"
var levels : Dictionary
var LEVELS_FILE_PATH : String = "user://levels.cfg"
var _configFile : ConfigFile
@export var current_world : String
@export var current_level : String

func _init():
	# Load available worlds and levels
	var dir : DirAccess = DirAccess.open(levels_path)
	if not dir:
		printerr("Warning: could not open directory: ", levels_path)
		return
	var dirs = dir.get_directories()
	for world in dirs:
		var world_dir_path : String = levels_path + "/" + world
		var sub_dir = DirAccess.open(world_dir_path)
		var world_files : Array = sub_dir.get_files()
		var world_levels : Array = []
		for file in world_files:
			if file.ends_with(".tscn") or file.ends_with(".tscn.remap"):
				world_levels.append(file.trim_suffix(".remap"))
		if world_levels.size() >= 1:
			world_levels.sort()
			levels[world] = world_levels
	print(levels)

	# Load user progress
	_configFile = ConfigFile.new()
	var err = _configFile.load(LEVELS_FILE_PATH)
	if err != OK:
		print("Error while loading config file: " + str(err))
	var worlds = levels.keys()
	var first_world = null
	var first_level = null
	if worlds.size() >= 1:
		worlds.sort()
		if levels[worlds[0]].size() >= 1:
			first_world = worlds[0]
			var first_world_levels = levels[worlds[0]]
			first_world_levels.sort()
			first_level = first_world_levels[0]
	current_world = _configFile.get_value("progress", "current_world", first_world)
	current_level = _configFile.get_value("progress", "current_level", first_level)
	print(current_world)
	print(current_level)


func add_level_button(container, text, level):
	"""Adds a working load level button to the scene"""
	var button : Button = load_level_button.instantiate()
	button.text = text
	if level == null:
		button.disabled = true
	else:
		button.disabled = false
		button.level = level
		button.connect("level_select", level_select)
	container.add_child(button)

func path_to_id(level: String):
	"""
	Returns a string with a level id (without a level prefix or
	an extension)
	"""
	return level.trim_prefix("level").trim_suffix(".tscn")

func _ready():
	# enable controller support
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()
	
	# represent world levels
	if levels.keys().find(current_world) == -1:
		current_world = levels.keys()[0]
		print(current_world)
	for level in levels[current_world]:
		add_level_button(levels_container, path_to_id(level), level)

	# show or hide world buttons
	if levels.size() != 1:
		subtitle_world.text = current_world.lstrip("0123456789")
	else:
		subtitle_world.hide()
	var world_index = levels.keys().find(current_world)
	if world_index == -1 or world_index == 0:
		previous_world_button.hide()
	else:
		previous_world_button.show()
	if world_index == -1 or world_index == levels.size() - 1:
		next_world_button.hide()
	else:
		next_world_button.show()

func level_select(level: String):
	"""Return feedback and load the given leven on the current world"""
	blip.play()
	await blip.finished
	var level_path : String = levels_path + "/" + current_world + "/" + level.trim_suffix(".remap")
	print("loading level " + level_path)
	get_tree().change_scene_to_file(level_path)

func load_next_level():
	pass
#	levels.remove_at(0)
#	if levels.size() == 0:
#		get_tree().quit()
#	else:
#		currentLevel = levels[0]
#		printerr("next level: ", levels_directory + currentLevel)
#		get_tree().change_scene_to_file(levels_directory + currentLevel)

func _process(_delta):
	pass

func go_back_to_main_menu():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_button_pressed():
	blip.play()
	await blip.finished
	go_back_to_main_menu()

func show_world(offset: int):
	"""
	Change the current world to the previous (-1) or next one (1),
	as defined by the offset.
	"""
	var world_index = levels.keys().find(current_world)
	if world_index == -1:
		return
	var new_world_index : int = world_index + offset
	if new_world_index < 0 or new_world_index > levels.size() - 1:
		return
	current_world = levels.keys()[new_world_index]
	print("Switching to world: ", current_world)
	_configFile.set_value("progress", "current_world", current_world)
	_configFile.save(LEVELS_FILE_PATH)

	# remove buttons and then redraw the screen
	for node in levels_container.get_children():
		node.queue_free()
	_ready()

func _on_previous_world_button_pressed():
	blip.play()
	show_world(-1)


func _on_next_world_button_pressed():
	blip.play()
	show_world(1)

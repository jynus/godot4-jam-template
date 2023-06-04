extends Button

@export var level : String

signal level_select(level)

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	level_select.emit(level)

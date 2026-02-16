extends Resource

class_name DialogueItem

@export var name: String
@export_multiline var dialogue: String
@export var sprite: Texture2D
@export var choices: Array[EventChoice]

func has_name() -> bool:
	if name:
		return true
	else: 
		return false

func has_choices() -> bool:
	if choices:
		return true
	else: 
		return false

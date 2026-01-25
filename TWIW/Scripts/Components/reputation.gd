extends Resource

class_name Reputation

@export var planet_name: StringName
@export_range(-100, 100) var reputation: int: set = on_reputation_changed

func on_reputation_changed(new_value: int) -> void:
	reputation = new_value

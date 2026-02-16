extends Resource

class_name Relevance

@export var planet_name: StringName
@export_range(0, 10) var relevance: int: set = on_relevance_changed

func on_relevance_changed(new_value: int) -> void:
	relevance = clampi(new_value, 0, 10)

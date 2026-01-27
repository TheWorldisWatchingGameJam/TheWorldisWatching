extends Resource

class_name TimeTracker

@export_range(0, 200) var current_day: int: set = current_day_set
@export var history: Array[EventHistoryEntry]

signal dayPassed

func current_day_set(new_value: int) -> void:
	for i in range(new_value - current_day):
		print("Day Passed.")
		emit_signal("dayPassed")
	current_day = new_value

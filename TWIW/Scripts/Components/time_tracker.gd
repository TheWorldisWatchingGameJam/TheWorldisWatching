extends Resource

class_name TimeTracker

@export_range(0, 300) var current_day: int 
@export var history: Array[EventHistoryEntry]

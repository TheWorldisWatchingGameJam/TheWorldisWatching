extends Resource

class_name EventHistoryEntry

@export var required_event_id: String = ""
@export var required_choice_id: String = ""
@export var must_have_completed: bool = true
@export var on_planet: StringName
@export var on_day: int

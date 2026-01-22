extends Resource

class_name Event

#Event descriptors
@export_group("Event Description")
@export var event_name: StringName
@export_multiline var event_desc: String
@export var event_icon_texture: Texture2D
@export var event_button_text: String

#Event execution
@export_group("Event Execution")
@export var home_exclusive: bool
@export var event_conditions: Array[EventCondition]
@export var dialogue: Array[DialogueItem]
@export var event_effects: Array[EventEffect]

#Event cost
@export_group("Event Cost")
@export var cost: Array[EventCost]

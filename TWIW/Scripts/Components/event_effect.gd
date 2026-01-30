extends Resource

class_name EventEffect

#Effect Type
@export var effect_value_token: EventCost
@export var effect_probability: int
@export var effect_dialogue: Array[DialogueItem]
@export var effect_delay: int

var delay_current_time := 0

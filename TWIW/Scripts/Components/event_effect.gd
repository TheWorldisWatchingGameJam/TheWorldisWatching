extends Resource
class_name EventEffect

@export var effect_value_token: EventCost
@export var effect_probability: int
@export var effect_dialogue: Array[DialogueItem]
@export var requirements: Array[EventEffectRequirement] = []

extends Resource

class_name EventEffect

#Effect Type
@export_enum("Food", "Luxury", "Weapons", "Rep", "Info", "Money") var effect_type: String
@export var effect_value: int
@export var effect_probability: int

#If effect is of type info or rep, check of which planet the effect should be effective upon
@export var on_planet: StringName

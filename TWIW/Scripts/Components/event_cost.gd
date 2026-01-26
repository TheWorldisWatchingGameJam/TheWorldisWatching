extends Resource

class_name EventCost

#Cost type
@export_enum("Food", "Luxuries", "Weapons", "Rep", "Info", "Money") var cost_type: String
@export var cost_value: int

#If cost is of type info or rep, check of which planet the cost should be deducted from
@export var on_planet: StringName
@export var on_current_planet: bool

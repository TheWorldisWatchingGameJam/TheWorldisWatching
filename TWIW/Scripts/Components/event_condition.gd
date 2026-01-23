extends Resource

class_name EventCondition

#History Conditions
@export var event_history_requirement: EventHistoryEntry
@export var relation_requirement: Relation
@export var war_event: bool

#Inventory Conditions
@export_enum("Food", "Luxuries", "Weapons", "Rep", "Info", "Money") var condition_type: String
@export var condition_value: int

#If condition is of type info or rep, check of which planet the cndition should be checked from
@export var on_planet: StringName

extends Resource

class_name PlanetData

#Planet identifiers
@export_group("Planet Identifiers")
@export var id: String
@export var name: StringName
@export var sprite: Texture2D
@export_multiline var desc: String

#Planet production values
@export_group("Planet Production")
@export var food_prod: int
@export var luxury_prod: int
@export var weapon_prod: int

#Planet demand values
@export_group("Planet Demand")
@export var food_demand: int
@export var luxury_demand: int
@export var weapon_demand: int

#Planet relation values
@export_group("Planet Relations")
@export var current_relations: Array[Relation]
@export var current_reputation: Array[Reputation]
@export var current_info: Array[Info]

#Planet event data
@export_group("Planet Events")
@export var event_pool: Array[Event]
@export var live_events: Array[Event]
@export var event_history: Array[Event]


func roll_events(number_of_events: int) -> Array[Event]:
	var list: Array[Event]
	for i in range(number_of_events):
		randomize()
		list.append(get_random_option())
	return list


func get_random_option():
	event_pool.pick_random()


func modify_info(planet_name: StringName, info_value: int) -> void:
	for x in current_info:
		if x.planet_name == planet_name:
			x.info += info_value

func modify_reputation(planet_name: StringName, rep_value: int) -> void:
	for x in current_reputation:
		if x.planet_name == planet_name:
			x.reputation += rep_value

func modify_relations(planet_name: StringName, relation: String) -> void:
	for x in current_relations:
		if x.planet_name == planet_name:
			x.relation= relation

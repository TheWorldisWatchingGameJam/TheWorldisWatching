extends Resource

class_name PlanetData

signal currentReputationChanged

#Planet identifiers
@export_group("Planet Identifiers")
@export var id: String
@export var name: StringName
@export var sprite: Texture2D
@export_multiline var desc: String

#Planet production values
@export_group("Planet Production")
@export_enum("Food", "Luxuries", "Weapons") var major_export: String
@export var food_prod: int
@export var luxury_prod: int
@export var weapon_prod: int

#Planet demand values
@export_group("Planet Demand")
@export var food_demand: int
@export var luxury_demand: int
@export var weapon_demand: int

#Planet threaten data
@export_group("Planet Threaten Event")
@export var weapons: int
@export var max_threaten_reward: EventCost

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

func get_random_option() -> Event:
	return event_pool.pick_random()

func modify_info(planet_name: StringName, info_value: int) -> void:
	for x in current_info:
		if x.planet_name == planet_name:
			x.info += info_value

func modify_reputation(planet_name: StringName, rep_value: int) -> void:
	print("Attempting to modify relation at ", planet_name, " by ", str(rep_value))
	for x in current_reputation:
		if x.planet_name == planet_name:
			x.reputation += rep_value
			print("currentReputationChanged signal emitted.")
			emit_signal("currentReputationChanged")

func modify_production(production_type: String, value: int) -> void:
	match production_type:
		"Food":
			food_prod += value
			print("Food production being modified by ", value)
		"Luxuries":
			luxury_prod += value
			print("Luxury production being modified by ", value)
		"Weapons":
			weapon_prod += value
			print("Weapons production being modified by ", value)
		_:
			print("Production value type not found.")

func modify_relations(planet_name: StringName, relation: String) -> void:
	for x in current_relations:
		if x.planet_name == planet_name:
			x.relation = relation

func get_reputation(from_planet: StringName) -> int:
	for x in current_reputation:
		if from_planet == x.planet_name:
			return x.reputation
	return 0

func threaten(player_weapon_value: int) -> EventCost:
	print("Player Threatens Planet.")
	if player_weapon_value - weapons >= max_threaten_reward.cost_value:
		print("Player gets max reward of: ", max_threaten_reward.cost_value, " ", max_threaten_reward.cost_type)
		return max_threaten_reward
	else: 
		if player_weapon_value <= 0:
			print("Player does not have enough Weapons to threaten this planet.")
			return null
		else:
			var threaten_reward = max_threaten_reward
			threaten_reward.cost_value = player_weapon_value - weapons
			print("Player gets max reward of: ", threaten_reward.cost_value, " ", threaten_reward.cost_type)
			return threaten_reward

func get_production(resource_type: String) -> int:
	print("Checking player's ", resource_type, " production.")
	match resource_type:
		"Food": 
			return food_prod
		"Luxuries":
			return luxury_prod
		"Weapons":
			return weapon_prod
		_:
			return 0

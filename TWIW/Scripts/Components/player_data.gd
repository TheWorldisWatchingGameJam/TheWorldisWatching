@tool
extends Resource

class_name PlayerData

signal playerDataChanged

var _food := 0
var _luxuries := 0
var _weapons := 0
var _money := 0
var _total_rep := 0

@export var home_planet_data: PlanetData: set = on_home_planet_data_set
@export var time_tracker: TimeTracker
@export var trade_routes: Array[TradeRoute]

@export_range(0, 999999, 1)
var food: int:
	get: return _food
	set(value):
		_food = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var luxuries: int:
	get: return _luxuries
	set(value):
		_luxuries = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var weapons: int:
	get: return _weapons
	set(value):
		_weapons = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var money: int:
	get: return _money
	set(value):
		_money = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var total_rep: int:
	get: return _total_rep
	set(value):
		_total_rep = value
		emit_signal("playerDataChanged")

func can_pay(cost_token: EventCost) -> bool:
	match cost_token.cost_type:
		"Food":
			return (food + cost_token.cost_value) >= 0
		"Luxuries":
			return (luxuries + cost_token.cost_value) >= 0
		"Weapons":
			return (weapons + cost_token.cost_value) >= 0
		"Money":
			return (money + cost_token.cost_value) >= 0
		_:
			return 0


func player_data_modify(cost_token: EventCost) -> void:
	print("Player resource, " + cost_token.cost_type + ", being modified by ", str(cost_token.cost_value)) 
	match cost_token.cost_type:
		"Food":
			food += cost_token.cost_value
		"Luxuries":
			luxuries += cost_token.cost_value
		"Weapons":
			weapons += cost_token.cost_value
		"Money":
			money += cost_token.cost_value
		"Rep":
			home_planet_data.modify_reputation(cost_token.on_planet, cost_token.cost_value)
			for item in home_planet_data.current_reputation:
				print("Reputation at ", item.planet_name, " is ", item.reputation)


func on_home_planet_data_set(new_value: PlanetData) -> void:
	print("Player home planet set to ", new_value.name)
	home_planet_data = new_value

func update_total_rep():
	print("Updating total rep...")
	var new_total_rep := 0
	for on_planet in home_planet_data.current_reputation:
		new_total_rep += on_planet.reputation
	total_rep = new_total_rep

func initialize_reputation_values(planets: Array[PlanetData]) -> void:
	#set rep values to zero
	for planet in planets:
		var new_rep_value = Reputation.new()
		new_rep_value.planet_name = planet.name
		new_rep_value.reputation = 0
		home_planet_data.current_reputation.append(new_rep_value)
	#connect signals to update_total_rep
	for planet in home_planet_data.current_reputation:
		total_rep += planet.reputation
	update_total_rep()

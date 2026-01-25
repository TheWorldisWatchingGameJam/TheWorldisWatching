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
			for planet in home_planet_data.current_reputation:
				if cost_token.on_planet == planet.planet_name:
					planet.reputation += cost_token.cost_value

func on_home_planet_data_set(new_value: PlanetData) -> void:
	home_planet_data = new_value
	for planet in home_planet_data.current_reputation:
		total_rep += planet.reputation
		home_planet_data.currentReputationChanged.connect(update_total_rep)

func update_total_rep():
	var new_total_rep := 0
	for on_planet in home_planet_data.current_reputation:
		new_total_rep += on_planet.reputation
	total_rep = new_total_rep

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
		_food = max(value, 0)
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var luxuries: int:
	get: return _luxuries
	set(value):
		_luxuries = max(value, 0)
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var weapons: int:
	get: return _weapons
	set(value):
		_weapons = max(value, 0)
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var money: int:
	get: return _money
	set(value):
		_money = max(value, 0)
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
			update_total_rep()
			for item in home_planet_data.current_reputation:
				print("Reputation at ", item.planet_name, " is ", item.reputation)
		"FoodProd":
			home_planet_data.apply_production_cost(cost_token)
			print("New Food Production: ", home_planet_data.food_prod)
		"LuxuryProd":
			home_planet_data.apply_production_cost(cost_token)
			print("New Luxury Production: ", home_planet_data.luxury_prod)
		"WeaponProd":
			home_planet_data.apply_production_cost(cost_token)
			print("New Weapon Production: ", home_planet_data.weapon_prod)

	print("=== END MODIFY PLAYER DATA ===\n")


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

func initialize_time_tracker() -> void:
	time_tracker = TimeTracker.new()
	time_tracker.dayPassed.connect(simulate_day)

func simulate_day() -> void:
	print("Day Simulating...")
	execute_trade_routes(trade_routes)
	produce_goods(home_planet_data)
	

func produce_goods(planet_data: PlanetData) -> void:
	print("===Producing Goods===")
	var food_token = EventCost.new()
	food_token.cost_type = "Food"
	food_token.cost_value += planet_data.food_prod
	print("Producing ", str(food_token.cost_value), " ", food_token.cost_type)
	player_data_modify(food_token)
	
	var luxury_token = EventCost.new()
	luxury_token.cost_type = "Luxuries"
	luxury_token.cost_value += planet_data.luxury_prod
	print("Producing ", str(luxury_token.cost_value), " ", luxury_token.cost_type)
	player_data_modify(luxury_token)
	
	var weapon_token = EventCost.new()
	weapon_token.cost_type = "Weapons"
	weapon_token.cost_value += planet_data.weapon_prod
	print("Producing ", str(weapon_token.cost_value), " ", weapon_token.cost_type)
	player_data_modify(weapon_token)


func execute_trade_routes(routes: Array[TradeRoute]):
	print("-==Trade Routes Being Executed==-")
	var expired_routes: Array[TradeRoute]
	for route in routes:
		print("Executing route to ", route.to_planet)
		print("Route Export: ", route.export.cost_value, " ", route.export.cost_type)
		print("Route Import: ", route.import.cost_value, " ", route.import.cost_type)

		if route.current_lifetime == route.max_duration:
			expired_routes.append(route)
			print("Route expired.")
			continue
		if route.executed == true:
			route.current_lifetime += 1
			print("Route has already been executed. Trade route lifetime: ", str(route.current_lifetime))
			player_data_modify(route.import)
			apply_rep_bonus(route)
			if route.current_lifetime == route.max_duration:
				expired_routes.append(route)
				var route_refund = EventCost.new()
				route_refund.cost_type = route.export.cost_type
				route_refund.cost_value = route.export.cost_value * -1
				player_data_modify(route_refund)
				print("Route expired.")
			continue
		if route.executed == false:
			print("Route has not been executed. Executing...")
			player_data_modify(route.export)
			player_data_modify(route.import)
			apply_rep_bonus(route)
			route.executed = true
	#After iteration remove expired routes
	for route in expired_routes:
		routes.erase(route)

func apply_rep_bonus(route: TradeRoute) -> void:
	var rep_bonus = EventCost.new()
	rep_bonus.cost_type = "Rep"
	rep_bonus.on_planet = route.to_planet.name

	match route.export.cost_type:
		"FoodProd":
			if route.to_planet.food_demand > 3:
				rep_bonus.cost_value = 1
		"LuxuryProd":
			rep_bonus.cost_value = 2
		"WeaponProd":
			if route.to_planet.weapon_demand > 2:
				rep_bonus.cost_value = 1
	player_data_modify(rep_bonus)
	

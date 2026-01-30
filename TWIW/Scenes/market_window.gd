extends Control

@export var planet: PlanetData
@export var player_data: PlayerData

@export var food_price: int
@export var luxuries_price: int
@export var weapons_price: int

@onready var market_name_label = %MarketNameLabel
@onready var food_current_price_label = %FoodCurrentPriceLabel
@onready var luxuries_current_price_label = %LuxuriesCurrentPriceLabel
@onready var weapons_current_price_label = %WeaponsCurrentPriceLabel


signal marketWindowClosed

func _ready() -> void:
	calculate_prices(planet)
	market_name_label.text = str("Welcome to the ", planet.name, " Market!")
	food_current_price_label.text = str("Current Price: ", food_price)
	luxuries_current_price_label.text = str("Current Price: ", luxuries_price)
	weapons_current_price_label.text = str("Current Price: ", weapons_price)


func _on_food_sell_button_pressed() -> void:
	var food_cost_token = EventCost.new()
	food_cost_token.cost_type = "Food"
	food_cost_token.cost_value = -1
	if not player_data.can_pay(food_cost_token):
		print("Not enough food in player inventory.")
		return
	player_data.player_data_modify(food_cost_token)
	player_data.money += food_price
	print("Player now has ", str(player_data.food), " food, and ", str(player_data.money), " money")


func _on_luxuries_sell_button_pressed() -> void:
	var luxury_cost_token = EventCost.new()
	luxury_cost_token.cost_type = "Luxuries"
	luxury_cost_token.cost_value = -1
	if not player_data.can_pay(luxury_cost_token):
		print("Not enough luxuries in player inventory.")
		return
	player_data.player_data_modify(luxury_cost_token)
	player_data.money += luxuries_price
	print("Player now has ", str(player_data.luxuries), " luxuries and ", str(player_data.money), " money")


func _on_weapons_sell_button_pressed() -> void:
	var weapon_cost_token = EventCost.new()
	weapon_cost_token.cost_type = "Weapons"
	weapon_cost_token.cost_value = -1
	if not player_data.can_pay(weapon_cost_token):
		print("Not enough weapons in player inventory.")
		return
	player_data.player_data_modify(weapon_cost_token)
	player_data.money += weapons_price
	print("Player now has ", str(player_data.weapons), " weapons and ", str(player_data.money), " money")


func calculate_prices(planet: PlanetData) -> void:
	if planet.food_demand > 0:
		var new_food_price = (int((float(planet.food_demand)/5) * 20)) + [-1, 0, 0, +1].pick_random()
		if new_food_price <= 0:
			new_food_price = 1
		food_price = new_food_price
	if planet.luxury_demand > 0:
		var new_luxuries_price = (int((float(planet.luxury_demand)/5) * 20)) + [-1, 0, 0, +1].pick_random()
		if new_luxuries_price <= 0:
			new_luxuries_price = 1
		luxuries_price = new_luxuries_price
	if planet.weapon_demand > 0:
		var new_weapons_price = (int((float(planet.weapon_demand)/5) * 20)) + [-1, 0, 0, +1].pick_random()
		if new_weapons_price <= 0:
			new_weapons_price = 1
		weapons_price = new_weapons_price


func _on_close_button_pressed() -> void:
	emit_signal("marketWindowClosed")

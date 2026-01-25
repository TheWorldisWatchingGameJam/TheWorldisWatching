extends Control

@export var planet: PlanetData
@export var player_data: PlayerData

@export var food_price: int
@export var luxuries_price: int
@export var weapons_price: int

@onready var food_current_price_label = %FoodCurrentPriceLabel
@onready var luxuries_current_price_label = %LuxuriesCurrentPriceLabel
@onready var weapons_current_price_label = %WeaponsCurrentPriceLabel

signal marketWindowClosed

func _ready() -> void:
	calculate_prices(planet)
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
		food_price = planet.food_demand + [-1, 0, 1, 2].pick_random()
	if planet.luxury_demand > 0:
		luxuries_price = planet.luxury_demand + [-1, 0, 1, 2].pick_random()
	if planet.weapon_demand > 0:
		weapons_price = planet.weapon_demand + [-1, 0, 1, 2].pick_random()


func _on_close_button_pressed() -> void:
	emit_signal("marketWindowClosed")

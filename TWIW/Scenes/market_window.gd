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
	player_data.food -= 1
	player_data.money += food_price
	print("Player now has ", str(player_data.food), " food, and ", str(player_data.money), " money")


func _on_luxuries_sell_button_pressed() -> void:
	player_data.luxuries -= 1
	player_data.money += luxuries_price
	print("Player now has ", str(player_data.luxuries), " food, and ", str(player_data.money), " money")


func _on_weapons_sell_button_pressed() -> void:
	player_data.weapons -= 1
	player_data.money += weapons_price
	print("Player now has ", str(player_data.weapons), " food, and ", str(player_data.money), " money")


func calculate_prices(planet: PlanetData) -> void:
	if planet.food_demand > 0:
		food_price = planet.food_demand + [-1, 1, 2, 3].pick_random()
	if planet.luxury_demand > 0:
		luxuries_price = planet.luxury_demand + [-1, 1, 2, 3].pick_random()
	if planet.weapon_demand > 0:
		weapons_price = planet.weapon_demand + [-1, 1, 2, 3].pick_random()


func _on_close_button_pressed() -> void:
	emit_signal("marketWindowClosed")

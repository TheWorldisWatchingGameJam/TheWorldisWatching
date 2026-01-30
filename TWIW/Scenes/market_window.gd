extends Control

@export var planet: PlanetData
@export var player_data: PlayerData

@export var food_price: int
@export var luxuries_price: int
@export var weapons_price: int

@export var not_enough_resources_message: Array[DialogueItem]

@onready var market_name_label = %MarketNameLabel
@onready var food_current_price_label = %FoodCurrentPriceLabel
@onready var luxuries_current_price_label = %LuxuriesCurrentPriceLabel
@onready var weapons_current_price_label = %WeaponsCurrentPriceLabel

@onready var food_slider_label = %FoodSliderLabel
@onready var luxury_slider_label = %LuxurySliderLabel
@onready var weapon_slider_label = %WeaponSliderLabel
@onready var food_slider = %FoodSlider
@onready var luxury_slider = %LuxurySlider
@onready var weapon_slider = %WeaponSlider


signal marketWindowClosed

func _ready() -> void:
	calculate_prices(planet)
	market_name_label.text = str("Welcome to the ", planet.name, " Market!")
	food_current_price_label.text = str("Current Price: ", food_price)
	luxuries_current_price_label.text = str("Current Price: ", luxuries_price)
	weapons_current_price_label.text = str("Current Price: ", weapons_price)
	
	food_slider_label.text = str(food_slider.value)
	luxury_slider_label.text = str(luxury_slider.value)
	weapon_slider_label.text = str(weapon_slider.value)
	


func _on_food_sell_button_pressed() -> void:
	var food_cost_token = EventCost.new()
	food_cost_token.cost_type = "Food"
	food_cost_token.cost_value = food_slider.value * -1
	if not player_data.can_pay(food_cost_token):
		var error_message_window = load("res://Scenes/dialogue_window.tscn").instantiate()
		error_message_window.dialogue_array = not_enough_resources_message
		self.add_child(error_message_window)
		error_message_window.dialogueFinished.connect(on_dialogue_finished.bind(error_message_window))
		print("Not enough food in player inventory.")
		return
	player_data.player_data_modify(food_cost_token)
	player_data.money += food_price
	print("Player now has ", str(player_data.food), " food, and ", str(player_data.money), " money")


func _on_luxuries_sell_button_pressed() -> void:
	var luxury_cost_token = EventCost.new()
	luxury_cost_token.cost_type = "Luxuries"
	luxury_cost_token.cost_value = luxury_slider.value * -1
	if not player_data.can_pay(luxury_cost_token):
		var error_message_window = load("res://Scenes/dialogue_window.tscn").instantiate()
		error_message_window.dialogue_array = not_enough_resources_message
		self.add_child(error_message_window)
		error_message_window.dialogueFinished.connect(on_dialogue_finished.bind(error_message_window))
		print("Not enough luxuries in player inventory.")
		return
	player_data.player_data_modify(luxury_cost_token)
	player_data.money += luxuries_price
	print("Player now has ", str(player_data.luxuries), " luxuries and ", str(player_data.money), " money")


func _on_weapons_sell_button_pressed() -> void:
	var weapon_cost_token = EventCost.new()
	weapon_cost_token.cost_type = "Weapons"
	weapon_cost_token.cost_value = weapon_slider.value * -1
	if not player_data.can_pay(weapon_cost_token):
		var error_message_window = load("res://Scenes/dialogue_window.tscn").instantiate()
		error_message_window.dialogue_array = not_enough_resources_message
		self.add_child(error_message_window)
		error_message_window.dialogueFinished.connect(on_dialogue_finished.bind(error_message_window))
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

func _on_food_slider_value_changed(value: float) -> void:
	food_slider_label.text = str(value)

func _on_luxury_slider_value_changed(value: float) -> void:
	luxury_slider_label.text = str(value)
	
func _on_weapon_slider_value_changed(value: float) -> void:
	weapon_slider_label.text = str(value)

func on_dialogue_finished(window: Control) -> void:
	window.queue_free()

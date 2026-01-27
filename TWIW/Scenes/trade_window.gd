extends Control

@export var player_data: PlayerData
@export var planet: PlanetData: set = planet_data_set
@export var food_cost_for_trade_route: EventCost
@export var trade_tutorial: Array[DialogueItem]
@export var no_cost_type_message: Array[DialogueItem]
@export var not_enough_production_message: Array[DialogueItem]

@onready var food_trade_button = %FoodTradeButton
@onready var luxuries_trade_button = %LuxuriesTradeButton
@onready var weapons_trade_button = %WeaponsTradeButton
@onready var money_trade_button = %MoneyTradeButton

@onready var food_number_button = %FoodNumberButton
@onready var luxuries_number_button = %LuxuriesNumberButton
@onready var weapons_number_button = %WeaponsNumberButton

@onready var all_trade_buttons = [food_trade_button, luxuries_trade_button, weapons_trade_button, food_number_button, luxuries_number_button, weapons_number_button]

@onready var establish_trade_button = %EstablishTradeButton
@onready var import_label = %ImportLabel

@onready var food_demand: int
@onready var luxury_demand: int
@onready var weapon_demand: int
@onready var export := EventCost.new()
@onready var import := EventCost.new()

@onready var trade_route_established_label = %TradeRouteEstablishedLabel
@onready var trade_window = %TradeWindow
@onready var trade_name_label = %TradeNameLabel

signal tradeWindowClosed

func _ready() -> void:
	export.cost_value = -1
	print("Export value set to: ", str(export.cost_value))


func planet_data_set(new_value: PlanetData) -> void:
	planet = new_value
	print("Trade window planet set to ", planet.name)
	await ready
	initialize_trade_window(planet)


func initialize_trade_window(planet: PlanetData) -> void:
	print("Trade Window Initializing...")
	#Set trade window label
	trade_name_label.text = str("Establish a Trade Route at ", planet.name)
	
	#Check if player already has a trade route to this planet
	for route in player_data.trade_routes:
		if route.to_planet == planet:
				trade_route_established_label.text = str("Trade Route Already Established.\nExporting: ", str(route.export.cost_value * -1), " ", route.export.cost_type, "\nImporting: ", route.import.cost_value, " ", route.import.cost_type)
				trade_window.hide()
				trade_route_established_label.visible = true
				return
	
	#If player has no active trade route, ensure right windows are showing
	trade_window.visible = true
	trade_route_established_label.hide()
	
	#If no trade route initialize demand values and show trade container 
	food_demand = planet.food_demand
	luxury_demand = planet.luxury_demand
	weapon_demand  = planet.weapon_demand
	


func _on_food_trade_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hide_all_buttons_except([food_number_button, food_trade_button])
		export.cost_type = "Food"
		print("Export cost type set to: ", export.cost_type)
		update_import_label()
	else:
		reset_all_buttons()

func _on_luxuries_trade_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hide_all_buttons_except([luxuries_number_button, luxuries_trade_button])
		export.cost_type = "Luxuries"
		print("Export cost type set to: ", export.cost_type)
		update_import_label()
	else:
		reset_all_buttons()

func _on_weapons_trade_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hide_all_buttons_except([weapons_number_button, weapons_trade_button])
		export.cost_type = "Weapons"
		print("Export cost type set to: ", export.cost_type)
		update_import_label()
	else:
		reset_all_buttons()

#DISREGARD
#func _on_money_trade_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#hide_all_buttons_except([money_trade_button])
		#export.cost_type = "Money"
		#print("Export cost type set to: ", export.cost_type)
	#else:
		#reset_all_buttons()
#DISREGARD

func hide_all_buttons_except(buttons_to_show: Array) -> void:
	var button_list = all_trade_buttons.duplicate()
	for button in buttons_to_show:
		button_list.erase(button)
	for button in button_list:
		button.hide()

func reset_all_buttons() -> void:
	for button in all_trade_buttons:
		button.visible = true


func _on_establish_trade_button_pressed() -> void:
	#Show error if export type not set
	if not export.cost_type:
		print("No export cost type set.")
		var info_window = load("res://Scenes/dialogue_window.tscn").instantiate()
		info_window.dialogue_array = no_cost_type_message
		info_window.dialogueFinished.connect(close_tutorial_dialogue.bind(info_window))
		self.add_child(info_window)
		return
		
	if player_data.home_planet_data.get_production(export.cost_type) < (export.cost_value * -1):
		print("Exported items exceed player's home planet production!")
		var info_window = load("res://Scenes/dialogue_window.tscn").instantiate()
		info_window.dialogue_array = not_enough_production_message
		info_window.dialogueFinished.connect(close_tutorial_dialogue.bind(info_window))
		self.add_child(info_window)
		return
		
	var new_trade_route = TradeRoute.new()

	new_trade_route.from_planet = player_data.home_planet_data
	new_trade_route.to_planet = planet
	new_trade_route.export = export
	new_trade_route.import = construct_import_token()
	
	print("--NEW TRADE ROUTE ESTABLISHED--")
	print("Trading from: ", new_trade_route.from_planet.name)
	print("Trading to: ", new_trade_route.to_planet.name)
	print("Exporting ", export.cost_value, " ", export.cost_type)
	print("Importing ", import.cost_value, " ", import.cost_type)
	

	player_data.trade_routes.append(new_trade_route) 
	player_data.player_data_modify(food_cost_for_trade_route)
	trade_route_established_label.text = str("Trade Route Already Established.\nExporting: ", str(export.cost_value * -1), " ", export.cost_type, "\nImporting: ", import.cost_value, " ", import.cost_type)
	trade_window.hide()
	trade_route_established_label.visible = true


func construct_import_token() -> EventCost:
	match export.cost_type:
		"Food":
			import.cost_type = "Money"
			import.cost_value = food_demand * (export.cost_value * -1)
		"Luxuries":
			import.cost_type = "Money"
			import.cost_value = luxury_demand * (export.cost_value  * -1)
		"Weapons":
			import.cost_type = "Money"
			import.cost_value = weapon_demand * (export.cost_value * -1)
		"Money":
			import.cost_type = planet.major_export
			import.cost_value = 1
	return import


func update_import_label() -> void:
		import = construct_import_token()
		import_label.text = str(str(import.cost_value), " ", import.cost_type)


func _on_food_number_button_item_selected(index: int) -> void:
	export.cost_value = int(food_number_button.get_item_text(index)) * -1
	print("Export value set to: ", str(export.cost_value))



func _on_luxuries_number_button_item_selected(index: int) -> void:
	export.cost_value = int(luxuries_number_button.get_item_text(index)) * -1
	print("Export value set to: ", str(export.cost_value))


func _on_weapons_number_button_item_selected(index: int) -> void:
	export.cost_value = int(weapons_number_button.get_item_text(index)) * -1
	print("Export value set to: ", str(export.cost_value))


func _on_close_button_pressed() -> void:
	emit_signal("tradeWindowClosed")


func _on_about_button_pressed() -> void:
	var info_window = load("res://Scenes/dialogue_window.tscn").instantiate()
	info_window.dialogue_array = trade_tutorial
	info_window.dialogueFinished.connect(close_tutorial_dialogue.bind(info_window))
	self.add_child(info_window)

func close_tutorial_dialogue(window: Control) -> void:
	window.queue_free()

extends Control

@export var player_data: PlayerData
@export var home_planet_data: PlanetData

@onready var food_value_label = $PanelContainer/VBoxContainer/HBoxContainer/FoodValue
@onready var luxuries_value_label = $PanelContainer/VBoxContainer/HBoxContainer/LuxuryValue
@onready var weapons_value_label = $PanelContainer/VBoxContainer/HBoxContainer/WeaponsValue
@onready var money_value_label = $PanelContainer/VBoxContainer/HBoxContainer/MoneyValue
@onready var rep_meter = $PanelContainer/VBoxContainer/HBoxContainer/RepMeter
@onready var rep_value_label = $PanelContainer/VBoxContainer/HBoxContainer/RepMeter/RepValue

func _ready():
	if player_data:
		update_ui()
		player_data.playerDataChanged.connect(update_ui)

func update_ui():
	food_value_label.text = str(player_data.food)
	luxuries_value_label.text = str(player_data.luxuries)
	weapons_value_label.text = str(player_data.weapons)
	money_value_label.text = str(player_data.money)



#test button
func _on_test_button_pressed() -> void:
	player_data.food += 1

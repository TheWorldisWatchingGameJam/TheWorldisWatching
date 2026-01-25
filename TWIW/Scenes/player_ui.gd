extends Control

@export var player_data: PlayerData
@export var home_planet_data: PlanetData
@export var mod_label_settings: LabelSettings

@onready var food_value_label = $PanelContainer/VBoxContainer/HBoxContainer/FoodValue
@onready var luxuries_value_label = $PanelContainer/VBoxContainer/HBoxContainer/LuxuryValue
@onready var weapons_value_label = $PanelContainer/VBoxContainer/HBoxContainer/WeaponsValue
@onready var money_value_label = $PanelContainer/VBoxContainer/HBoxContainer/MoneyValue
@onready var rep_meter = $PanelContainer/VBoxContainer/HBoxContainer/RepMeter
@onready var rep_value_label = $PanelContainer/VBoxContainer/HBoxContainer/RepMeter/RepValue

@onready var food_mod_label = $FoodModLabel
@onready var luxury_mod_label = $LuxuryModLabel
@onready var weapons_mod_label = $WeaponsModLabel
@onready var money_mod_label = $MoneyModLabel
@onready var rep_mod_label = $RepModLabel

func _ready() -> void:
	var last_food_value: int
	
	if player_data:
		update_ui()
		player_data.playerDataChanged.connect(update_ui)

func update_ui() -> void:
	food_value_label.text = str(player_data.food)
	luxuries_value_label.text = str(player_data.luxuries)
	weapons_value_label.text = str(player_data.weapons)
	money_value_label.text = str(player_data.money)
	rep_meter.value = player_data.total_rep
	rep_value_label.text = str(player_data.total_rep)
	#Changing color of rep meter in response to negative and positive REP
	if player_data.total_rep < 0:
		rep_meter.self_modulate = Color.CRIMSON
	elif player_data.total_rep > 0:
		rep_meter.self_modulate = Color.LIME_GREEN
	elif player_data.total_rep == 0:
		rep_meter.self_modulate = Color.WHITE

#Defunct; but save for later
#func play_modification_animation() -> void:
	#var food_diff = int(food_value_label.text) - player_data.food
	#var luxury_diff = int(luxuries_value_label.text) - player_data.luxuries
	#var weapons_diff = int(weapons_value_label.text) - player_data.weapons
	#var money_diff = int(money_value_label.text) - player_data.money
	#var rep_diff = int(rep_value_label.text) - player_data.total_rep
	#
	#if food_diff != 0:
		#var new_food_mod_label = Label.new()
		#new_food_mod_label.text = str(food_diff)
		#new_food_mod_label.label_settings = mod_label_settings
		#new_food_mod_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#new_food_mod_label.vertical_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#new_food_mod_label.size = Vector2(100, 100)
		#new_food_mod_label.set_position(Vector2(85, 30))
		#if food_diff > 0:
			#new_food_mod_label.self_modulate = Color.CRIMSON
			#new_food_mod_label.visible = true
			#float_label(new_food_mod_label)
		#if food_diff < 0:
			#new_food_mod_label.self_modulate = Color.LIME_GREEN
			#new_food_mod_label.visible = true
			#float_label(new_food_mod_label)



#func float_label(label: Label) -> void:
		#var tween = get_tree().create_tween()
		#tween.tween_property(label, "scale", 1.25, 0.5)
		#tween.tween_property(label, "position", (label.global_position + Vector2(0, 30)), 0.5)
		#tween.tween_callback(label.hide)


##test button
#func _on_test_button_pressed() -> void:
	#player_data.food += 1

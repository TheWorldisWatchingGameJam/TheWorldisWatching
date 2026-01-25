extends Control

@export var planet: PlanetData 
@export var player_data: PlayerData
@export var event_name_label_settings: LabelSettings
@export var event_desc_label_settings: LabelSettings

@onready var planet_window = %PlanetWindow
@onready var trade_button = %TradeButton
@onready var market_button = %MarketButton
@onready var threaten_button = %ThreatenButton
@onready var window = $Window
@onready var market_window = load("res://Scenes/market_window.tscn")


func _ready() -> void:
	await get_tree().process_frame
	initialize_market_window()
	display_options(random_options(3))
	reset_threaten_button()

func reset_threaten_button() -> void:
	threaten_button.disabled = false

func initialize_market_window() -> void:
	market_window = market_window.instantiate()
	market_window.marketWindowClosed.connect(on_market_window_closed)
	market_window.player_data = player_data
	market_window.planet = planet
	market_window.hide()
	self.add_child(market_window)

#Roll for x random events of given planet
func random_options(number_of_options: int) -> Array[Event]:
	var events = planet.roll_events(number_of_options)
	print("Generating Events for Planet: " + planet.name)
	print("---EVENTS---")
	for event in events:
		if event:
			print(event.event_name)
	return events

#Display the events rolled
func display_options(events: Array[Event]) -> void:
	for event in events:
		#Create event container
		var event_container = VBoxContainer.new()
		event_container.custom_minimum_size = Vector2(400,0)
		event_container.add_theme_constant_override(&"separation", 20)
		planet_window.add_child(event_container)
		
		#Display event name
		var event_name_label_container = PanelContainer.new()
		event_name_label_container.custom_minimum_size = Vector2(400,60)
		event_name_label_container.theme = load("res://Assets/Theme/button_theme.tres")
		event_container.add_child(event_name_label_container)
		var event_name_label = Label.new()
		event_name_label.text = event.event_name
		event_name_label.label_settings = event_name_label_settings
		event_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		event_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		event_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		event_name_label.custom_minimum_size = Vector2(400,0)
		event_name_label_container.add_child(event_name_label)
		
		#Display event icon
		var icon = TextureRect.new()
		icon.texture = event.event_icon_texture
		event_container.add_child(icon)
		
		#Display event description
		#First the Panel
		var event_desc_label_container = PanelContainer.new()
		event_desc_label_container.theme = load("res://Assets/Theme/button_theme.tres")
		event_desc_label_container.custom_minimum_size = Vector2(400,0)
		event_container.add_child(event_desc_label_container)
		#Vertical spacer container
		var event_desc_label_spacer_container_v = VBoxContainer.new()
		event_desc_label_container.add_child(event_desc_label_spacer_container_v)
		#Top spacer
		var event_desc_label_spacer_t = Control.new()
		event_desc_label_spacer_t.custom_minimum_size = Vector2(0, 10)
		event_desc_label_spacer_container_v.add_child(event_desc_label_spacer_t)
		#Horizontal spacer container
		var event_desc_label_spacer_container_h = HBoxContainer.new()
		event_desc_label_spacer_container_v.add_child(event_desc_label_spacer_container_h)
		#Left spacer
		var event_desc_label_spacer_l = Control.new()
		event_desc_label_spacer_l.custom_minimum_size = Vector2(10, 0)
		event_desc_label_spacer_container_h.add_child(event_desc_label_spacer_l)
		#Label in h container
		var event_desc_label = Label.new()
		event_desc_label.text = event.event_desc
		event_desc_label.label_settings = event_desc_label_settings
		event_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		event_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		event_desc_label.custom_minimum_size = Vector2(400,0)
		event_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		event_desc_label_spacer_container_h.add_child(event_desc_label)
		#Right spacer
		var event_desc_label_spacer_r = Control.new()
		event_desc_label_spacer_r.custom_minimum_size = Vector2(10, 0)
		event_desc_label_spacer_container_h.add_child(event_desc_label_spacer_r)
		#Bottom spacer
		var event_desc_label_spacer_b = Control.new()
		event_desc_label_spacer_b.custom_minimum_size = Vector2(0, 10)
		event_desc_label_spacer_container_v.add_child(event_desc_label_spacer_b)
		
		#Add spacer to button
		var spacer = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		event_container.add_child(spacer)
		
		#Display event button
		var button = Button.new()
		button.text = event.event_button_text
		button.theme = load("res://Assets/Theme/button_theme.tres")
		button.add_theme_font_size_override("font_size", 25)
		button.custom_minimum_size = Vector2(150, 40)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_END
		event_container.add_child(button)
		button.pressed.connect(_on_event_selected.bind(event))

func _on_event_selected(event: Event) -> void:
	print("Event Selected: " + event.event_name)
	print("---EVENT COSTS---")
	for cost in event.cost:
		if not player_data.can_pay(cost):
			print("Player cannot afford event cost!")
			return
	for cost in event.cost:
			player_data.player_data_modify(cost)
	leave_planet()

func _on_trade_button_pressed() -> void:
	var trade_window = load("res://Scenes/trade_window.tscn")
	trade_window.instantiate()

func _on_market_button_pressed() -> void:
	window.hide()
	market_window.visible = true

func on_market_window_closed() -> void:
	market_window.hide()
	window.visible = true

func _on_threaten_button_pressed() -> void:
	player_data.player_data_modify(planet.threaten(player_data.weapons)) # should return the number and resource demanded, if player loses, should return nothing
	threaten_button.disabled = true
	player_data.home_planet_data.modify_reputation(planet.name, -5)
	print("Player reputation at ", planet.name, " is now at ", player_data.home_planet_data.get_reputation(planet.name))

func leave_planet() -> void:
	pass

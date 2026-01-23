extends Control

@export var planet: PlanetData 
@export var player_data: PlayerData
@export var home_planet_data: PlanetData
@export var event_name_label_settings: LabelSettings
@export var event_desc_label_settings: LabelSettings

@onready var planet_window = $PlanetWindow


func _ready() -> void:
	display_options(roll_options(3))

#Roll for x random events of given planet
func roll_options(number_of_options: int) -> Array[Event]:
	var events = planet.roll_events(number_of_options)
	print("Generating Events for Planet: " + planet.name)
	print("---EVENTS---")
	for event in events:
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
		event_name_label_container.custom_minimum_size = Vector2(400,0)
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
		var event_desc_label_container = PanelContainer.new()
		event_desc_label_container.custom_minimum_size = Vector2(400,0)
		event_container.add_child(event_desc_label_container)
		var event_desc_label = Label.new()
		event_desc_label.text = event.event_desc
		event_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		event_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		event_desc_label.custom_minimum_size = Vector2(400,0)
		event_desc_label_container.add_child(event_desc_label)
		
		#Add spacer
		var spacer = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		event_container.add_child(spacer)
		
		#Display event button
		var button = Button.new()
		button.text = event.event_button_text
		event_container.add_child(button)
		button.pressed.connect(_on_event_selected.bind(event))


func _on_event_selected(event: Event) -> void:
	print("Event Selected: " + event.event_name)
	print("---EVENT COSTS---")
	for cost in event.cost:
		print("Paying cost of type: " + cost.cost_type) 
		print("Cost: ", str(cost.cost_value))
		match cost.cost_type:
			"Food":
				player_data.food -= cost.cost_value
			"Luxuries":
				player_data.luxuries -= cost.cost_value
			"Weapons":
				player_data.weapons -= cost.cost_value
			"Money":
				player_data.money -= cost.cost_value
			"Rep":
				pass
	planet_window.hide()
	
	


   

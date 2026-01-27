extends Control

var planet: PlanetData 
var player_data: PlayerData
var home_planet_data: PlanetData
var ai_data: AIData

@export var event_name_label_settings: LabelSettings
@export var event_desc_label_settings: LabelSettings

@onready var planet_window = %PlanetWindow
@onready var trade_button = %TradeButton
@onready var market_button = %MarketButton
@onready var threaten_button = %ThreatenButton
@onready var window = $Window
@onready var event_chosen_label = %EventChosenLabel
@onready var market_window = load("res://Scenes/market_window.tscn")
@onready var dialogue_window = load("res://Scenes/dialogue_window.tscn")
@onready var trade_window = load("res://Scenes/trade_window.tscn")

var current_dialogue_window: Control = null
var current_choice_panel: Control = null

signal eventChosen

func _ready() -> void:
	await get_tree().process_frame
	initialize_market_window()
	initialize_trade_window()
	display_options(random_options(3))
	threaten_button.disabled = false
	

func initialize_trade_window() -> void:
	trade_window = trade_window.instantiate()
	trade_window.tradeWindowClosed.connect(on_trade_window_closed)
	trade_window.player_data = player_data
	trade_window.planet = planet
	trade_window.hide()
	self.add_child(trade_window)

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
		var event_desc_label_container = PanelContainer.new()
		event_desc_label_container.theme = load("res://Assets/Theme/button_theme.tres")
		event_desc_label_container.custom_minimum_size = Vector2(400,0)
		event_container.add_child(event_desc_label_container)
		var event_desc_label_spacer_container_v = VBoxContainer.new()
		event_desc_label_container.add_child(event_desc_label_spacer_container_v)
		var event_desc_label_spacer_t = Control.new()
		event_desc_label_spacer_t.custom_minimum_size = Vector2(0, 10)
		event_desc_label_spacer_container_v.add_child(event_desc_label_spacer_t)
		var event_desc_label_spacer_container_h = HBoxContainer.new()
		event_desc_label_spacer_container_v.add_child(event_desc_label_spacer_container_h)
		var event_desc_label_spacer_l = Control.new()
		event_desc_label_spacer_l.custom_minimum_size = Vector2(10, 0)
		event_desc_label_spacer_container_h.add_child(event_desc_label_spacer_l)
		var event_desc_label = Label.new()
		event_desc_label.text = event.event_desc
		event_desc_label.label_settings = event_desc_label_settings
		event_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		event_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		event_desc_label.custom_minimum_size = Vector2(400,0)
		event_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		event_desc_label_spacer_container_h.add_child(event_desc_label)
		var event_desc_label_spacer_r = Control.new()
		event_desc_label_spacer_r.custom_minimum_size = Vector2(10, 0)
		event_desc_label_spacer_container_h.add_child(event_desc_label_spacer_r)
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
	# Pay cost first
	for cost in event.cost:
		if not player_data.can_pay(cost):
			print("Player cannot afford event cost!")
			return
	for cost in event.cost:
		player_data.player_data_modify(cost)

	# Handle dialogue + choices
	if event.choices.size() > 0:
		_show_choice_dialogue(event)
	else:
		resolve_event_effect(event.event_effects)
		emit_signal("eventChosen")

func _show_choice_dialogue(event: Event) -> void:
	# Remove old dialogue if it exists
	if current_dialogue_window:
		current_dialogue_window.queue_free()
		
	current_dialogue_window = dialogue_window.instantiate()
	current_dialogue_window.dialogue_array = event.event_dialogue
	current_dialogue_window.dialogueFinished.connect(_on_event_dialogue_finished.bind(event))
	window.hide()
	get_tree().get_root().add_child(current_dialogue_window)

func _on_event_dialogue_finished(event: Event) -> void:
	if event.choices.size() > 0:
		_show_choice_buttons(event.choices)
	else:
		resolve_event_effect(event.event_effects)
		emit_signal("eventChosen")

func _show_choice_buttons(choices: Array[EventChoice]) -> void:
	# Remove old choice panel if it exists
	if current_choice_panel:
		current_choice_panel.queue_free()
	
	if current_dialogue_window and current_dialogue_window.has_method("clear_dialogue"):
		current_dialogue_window.clear_dialogue()
	
	current_choice_panel = VBoxContainer.new()
	current_choice_panel.name = "ChoicePanel"
	current_choice_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	current_choice_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	current_choice_panel.add_theme_constant_override("separation", 10)

	for choice in choices:
		var btn = Button.new()
		btn.text = choice.choice_text
		btn.theme = load("res://Assets/Theme/button_theme.tres")
		btn.custom_minimum_size = Vector2(200, 50)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_END
		btn.pressed.connect(_on_choice_selected.bind(choice))
		current_choice_panel.add_child(btn)

	# Add choice panel to the dialogue window instead of root
	if current_dialogue_window:
		current_dialogue_window.add_child(current_choice_panel)

func _on_choice_selected(choice: EventChoice) -> void:
	print("=== CHOICE SELECTED ===")
	print("Choice: ", choice.choice_text)
	print("Has ", choice.choice_effects.size(), " effects")
	
	# Remove choice buttons
	if current_choice_panel:
		current_choice_panel.queue_free()
		current_choice_panel = null

	# Apply effects immediately
	print("Applying effects now...")
	resolve_event_effect(choice.choice_effects)
	
	# If the choice has dialogue, show it AFTER effects
	if choice.choice_dialogue.size() > 0:
		print("Showing choice dialogue...")
		if current_dialogue_window and current_dialogue_window.has_method("set_dialogue"):
			current_dialogue_window.set_dialogue(choice.choice_dialogue)
			current_dialogue_window.dialogueFinished.connect(func(_unused):
				emit_signal("eventChosen")
			, CONNECT_ONE_SHOT)
		else:
			if current_dialogue_window:
				current_dialogue_window.queue_free()
			
			current_dialogue_window = dialogue_window.instantiate()
			current_dialogue_window.dialogue_array = choice.choice_dialogue
			current_dialogue_window.dialogueFinished.connect(func(_unused):
				emit_signal("eventChosen")
			)
			get_tree().get_root().add_child(current_dialogue_window)
	else:
		print("No choice dialogue")
		emit_signal("eventChosen")

func resolve_event_effect(effects: Array[EventEffect]) -> void:
	print("=== RESOLVING EFFECTS ===")
	print("Total effects: ", effects.size())
	
	if effects.size() == 0:
		print("WARNING: No effects to apply!")
		return
	
	var guaranteed_effects = []
	var random_effects = []

	for effect in effects:
		if effect.effect_probability == 0:
			print("Found guaranteed effect")
			guaranteed_effects.append(effect)
		else:
			print("Found random effect with probability: ", effect.effect_probability)
			random_effects.append(effect)

	# Apply all guaranteed effects
	for effect in guaranteed_effects:
		print("Applying guaranteed effect: ", effect.effect_value_token.cost_type, " = ", effect.effect_value_token.cost_value)
		player_data.player_data_modify(effect.effect_value_token)
		if effect.effect_dialogue.size() > 0:
			var dlg = dialogue_window.instantiate()
			dlg.dialogue_array = effect.effect_dialogue
			dlg.dialogueFinished.connect(on_effect_dialogue_finished)
			window.hide()
			get_tree().get_root().add_child(dlg)

	# Pick one effect randomly from the remaining probabilistic ones
	if random_effects.size() > 0:
		var total = 0
		for e in random_effects:
			total += e.effect_probability
		var roll = randi() % total
		var cumulative = 0
		for e in random_effects:
			cumulative += e.effect_probability
			if roll < cumulative:
				print("Applying random effect: ", e.effect_value_token.cost_type, " = ", e.effect_value_token.cost_value)
				player_data.player_data_modify(e.effect_value_token)
				if e.effect_dialogue.size() > 0:
					var dlg = dialogue_window.instantiate()
					dlg.dialogue_array = e.effect_dialogue
					dlg.dialogueFinished.connect(on_effect_dialogue_finished)
					window.hide()
					get_tree().get_root().add_child(dlg)
				break
	
	print("=== EFFECTS APPLIED ===")

func on_effect_dialogue_finished() -> void:
	window.visible = true

func _on_trade_button_pressed() -> void:
	window.hide()
	trade_window.visible = true

func on_trade_window_closed() -> void:
	trade_window.hide()
	window.visible = true

func _on_market_button_pressed() -> void:
	window.hide()
	market_window.visible = true

func on_market_window_closed() -> void:
	market_window.hide()
	window.visible = true

func _on_threaten_button_pressed() -> void:
	player_data.player_data_modify(planet.threaten(player_data.weapons))
	threaten_button.disabled = true
	player_data.home_planet_data.modify_reputation(planet.name, -5)
	print("Player reputation at ", planet.name, " is now at ", player_data.home_planet_data.get_reputation(planet.name))

func _on_event_chosen() -> void:
	planet_window.hide()
	event_chosen_label.visible = true

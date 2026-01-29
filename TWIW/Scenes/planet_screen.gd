extends Control

var planet: PlanetData 
var player_data: PlayerData
var home_planet_data: PlanetData
var ai_data: AIData

@export var event_name_label_settings: LabelSettings
@export var event_desc_label_settings: LabelSettings

@onready var background = $Background
@onready var planet_window = %PlanetWindow
@onready var trade_button = %TradeButton
@onready var market_button = %MarketButton
@onready var threaten_button = %ThreatenButton
@onready var window = $Window
@onready var event_chosen_label = %EventChosenLabel
@onready var market_window = load("res://Scenes/market_window.tscn")
@onready var dialogue_window = load("res://Scenes/dialogue_window.tscn")
@onready var trade_window = load("res://Scenes/trade_window.tscn")
@onready var choice_panel = %ChoicePanel
@onready var selector = %Selector

var current_dialogue_window: Control = null
var current_choice_panel: Control = null

# Blackjack game state
var blackjack_active: bool = false
var blackjack_deck: Array = []
var blackjack_player_hand: Array = []
var blackjack_dealer_hand: Array = []
var blackjack_bet: int = 100

signal eventChosen

func _ready() -> void:
	await get_tree().process_frame
	background.texture = planet.bg
	initialize_market_window()
	initialize_trade_window()
	display_options(random_options(3))
	threaten_button.disabled = false
	choice_panel.hide()

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
	var all_events = planet.roll_events(number_of_options * 5)  # Get even more events to filter and avoid duplicates
	var valid_events: Array[Event] = []
	var priority_events: Array[Event] = []
	var seen_events: Dictionary = {}  # Track events to prevent duplicates
	
	print("Generating Events for Planet: " + planet.name)
	print("---EVENTS (with condition filtering)---")
	
	# Filter events that meet conditions and separate priority events
	for event in all_events:
		if not event:
			continue
		
		# Create a unique key for this event (prefer event_id, fallback to event_name)
		var event_key = ""
		if "event_id" in event and event.event_id != "":
			event_key = event.event_id
		elif "event_name" in event:
			event_key = event.event_name
		
		# Skip if we've already seen this event
		if event_key != "" and seen_events.has(event_key):
			print(event.event_name + " [DUPLICATE - SKIPPED]")
			continue
		
		if check_event_conditions(event):
			# Mark this event as seen
			if event_key != "":
				seen_events[event_key] = true
			
			# Check if event is marked as priority
			if "is_priority" in event and event.is_priority:
				priority_events.append(event)
				print(event.event_name + " [VALID - PRIORITY]")
			else:
				valid_events.append(event)
				print(event.event_name + " [VALID]")
		else:
			print(event.event_name + " [FILTERED OUT - conditions not met]")
	
	# Build result: priority events first, then fill with regular events
	var result: Array[Event] = []
	
	# Add all priority events first
	for priority_event in priority_events:
		if result.size() < number_of_options:
			result.append(priority_event)
	
	# Fill remaining slots with regular events
	for event in valid_events:
		if result.size() < number_of_options:
			result.append(event)
	
	# If we don't have enough events, add null placeholders
	while result.size() < number_of_options:
		result.append(null)
		print("Added placeholder for slot ", result.size())
	
	return result

# ============================================
# EVENT CONDITION SYSTEM (for filtering events)
# ============================================

func check_event_conditions(event: Event) -> bool:
	# If event has no event_conditions property or it's empty, event is valid
	if not "event_conditions" in event:
		return true
	if event.event_conditions == null or event.event_conditions.size() == 0:
		return true
	
	# All conditions must be met (AND logic)
	for condition in event.event_conditions:
		if not _check_event_condition(condition):
			print("Event condition not met for: ", event.event_name)
			return false
	
	return true

func _check_event_condition(condition: EventCondition) -> bool:
	print("--- Checking Event Condition ---")
	
	# Check war event requirement
	if "war_event" in condition and condition.war_event:
		print("War event check (not implemented, passing)")
		# You'll need to implement war state checking
		# For now, returning true - replace with actual war state check
		pass
	
	# Check event history requirement
	if "event_history_requirement" in condition and condition.event_history_requirement != null:
		print("Event history check...")
		var history_req = condition.event_history_requirement
		
		if "required_event_id" in history_req and history_req.required_event_id != "":
			var event_id = history_req.required_event_id
			var has_completed = player_data.has_completed_event(event_id)
			
			print("  Required event: ", event_id)
			print("  Player has completed: ", has_completed)
			
			# Check if must_have_completed matches the actual completion status
			if "must_have_completed" in history_req:
				if history_req.must_have_completed != has_completed:
					print("  FAILED: Event completion requirement not met")
					return false
			
			# If a specific choice is required, check that too
			if "required_choice_id" in history_req and history_req.required_choice_id != "":
				var choice_id = history_req.required_choice_id
				if not player_data.has_made_choice(event_id, choice_id):
					print("  FAILED: Required choice '", choice_id, "' was not made")
					return false
				print("  PASSED: Required choice '", choice_id, "' was made")
			
			print("  PASSED: Event history requirement met")
	
	# Check relation requirement
	if "relation_requirement" in condition and condition.relation_requirement != null:
		print("Relation check (not implemented, passing)")
		# You'll need to implement relation checking
		# For now, returning true - replace with actual relation check
		pass
	
	# Check resource conditions (Food, Luxuries, Weapons, Money, Rep, Info)
	if "condition_type" in condition and condition.condition_type != "":
		print("Has condition_type: ", condition.condition_type)
		return _check_resource_condition(condition)
	
	print("No specific condition type found, passing")
	return true

func _check_resource_condition(condition: EventCondition) -> bool:
	var player_value = 0
	
	print("=== CHECKING RESOURCE CONDITION ===")
	print("Condition Type: ", condition.condition_type)
	print("Condition Value Required: ", condition.condition_value)
	
	match condition.condition_type:
		"Food":
			player_value = player_data.food
			print("Player Food: ", player_value)
		"Money":
			player_value = player_data.money
			print("Player Money: ", player_value)
		"Weapons":
			player_value = player_data.weapons
			print("Player Weapons: ", player_value)
		"Luxuries":
			player_value = player_data.luxuries
			print("Player Luxuries: ", player_value)
		"Rep":
			# Check reputation with specific planet
			print("Checking Rep condition...")
			print("on_planet property exists: ", "on_planet" in condition)
			if "on_planet" in condition:
				print("on_planet value: ", condition.on_planet)
			
			if "on_planet" in condition and condition.on_planet != "":
				if player_data.home_planet_data:
					player_value = player_data.home_planet_data.get_reputation(condition.on_planet)
					print("Player Rep with ", condition.on_planet, ": ", player_value)
				else:
					print("ERROR: player_data.home_planet_data is null!")
					return false
			else:
				print("ERROR: Rep condition requires on_planet to be set")
				return false
		"Info":
			# Check if player has info about specific planet
			# You'll need to implement info checking based on your game logic
			# For now, returning true - replace with actual info check
			print("Info condition - returning true (not implemented)")
			return true
	
	# Compare player's value with condition requirement
	var result = player_value >= condition.condition_value
	print("Comparison: ", player_value, " >= ", condition.condition_value, " = ", result)
	print("=================================")
	return result

# ============================================
# END EVENT CONDITION SYSTEM
# ============================================

#Display the events rolled
func display_options(events: Array[Event]) -> void:
	for event in events:
		# Handle null events (no more available)
		if event == null:
			_display_no_events_card()
			continue
			
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

func _display_no_events_card() -> void:
	#Create event container
	var event_container = VBoxContainer.new()
	event_container.custom_minimum_size = Vector2(400,0)
	event_container.add_theme_constant_override(&"separation", 20)
	planet_window.add_child(event_container)
	
	#Display placeholder name
	var event_name_label_container = PanelContainer.new()
	event_name_label_container.custom_minimum_size = Vector2(400,60)
	event_name_label_container.theme = load("res://Assets/Theme/button_theme.tres")
	event_container.add_child(event_name_label_container)
	var event_name_label = Label.new()
	event_name_label.text = "No Events Available"
	event_name_label.label_settings = event_name_label_settings
	event_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	event_name_label.custom_minimum_size = Vector2(400,0)
	event_name_label_container.add_child(event_name_label)
	
	#Display placeholder description
	var event_desc_label_container = PanelContainer.new()
	event_desc_label_container.theme = load("res://Assets/Theme/button_theme.tres")
	event_desc_label_container.custom_minimum_size = Vector2(400,200)
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
	event_desc_label.text = "No other events are available at the moment. Try visiting other planets or completing certain events to unlock more opportunities here."
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
	
	#Add spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_container.add_child(spacer)

func _on_event_selected(event: Event) -> void:
	# Pay cost first
	for cost in event.cost:
		if not player_data.can_pay(cost):
			print("Player cannot afford event cost!")
			return
	for cost in event.cost:
		player_data.player_data_modify(cost)

	# Record event completion (without choice for now, will be updated if choice is made)
	if "event_id" in event and event.event_id != "":
		player_data.record_event_completion(event.event_id, "")

	# Always show dialogue/choices if they exist
	if event.event_dialogue.size() > 0 or event.choices.size() > 0:
		_show_choice_dialogue(event)
	else:
		resolve_effects(event.event_effects)
		emit_signal("eventChosen")

func _show_choice_dialogue(event: Event) -> void:
	# Check if this is a blackjack event
	if event.event_dialogue.size() > 0 and event.event_dialogue[0].dialogue == "[BLACKJACK]":
		_start_blackjack()
		return
	
	# Normal dialogue handling - initiate choice event
	_initiate_choice_event(event)

# Store the current event for choice recording
var current_event: Event = null

func _initiate_choice_event(event: Event) -> void:
	# Store current event so we can record choices
	current_event = event
	
	# Remove old dialogue if it exists
	if current_dialogue_window:
		current_dialogue_window.queue_free()
		
	current_dialogue_window = dialogue_window.instantiate()
	current_dialogue_window.dialogue_array = event.event_dialogue
	current_dialogue_window.dialogueFinished.connect(_on_choice_dialogue_finished.bind(event))
	window.hide()
	self.add_child(current_dialogue_window)

func _on_choice_dialogue_finished(event: Event) -> void:
	if event.choices.size() > 0:
		_show_choice_buttons(event.choices)
	else:
		# Event has no choices, so apply effects and finish
		if event.event_effects.size() > 0:
			resolve_effects(event.event_effects)
		else:
			# No effects either, just signal completion
			print("No effects to apply, event complete")
			emit_signal("eventChosen")

func _show_choice_buttons(choices: Array[EventChoice]) -> void:
	# Clear existing buttons in selector
	for child in selector.get_children():
		child.queue_free()
	
	for choice in choices:
		var btn = Button.new()
		btn.text = choice.choice_text
		btn.theme = load("res://Assets/Theme/button_theme.tres")
		btn.custom_minimum_size = Vector2(200, 50)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_END
		btn.pressed.connect(_on_choice_selected.bind(choice))
		selector.add_child(btn)

	choice_panel.get_parent().move_child(choice_panel, -1)
	choice_panel.visible = true

func _on_choice_selected(choice: EventChoice) -> void:
	print("=== CHOICE SELECTED ===")
	print("Choice: ", choice.choice_text)
	print("Has ", choice.choice_effects.size(), " effects")
	
	# Record the choice made (update the event completion with the choice_id)
	if current_event and "event_id" in current_event and current_event.event_id != "":
		if "choice_id" in choice and choice.choice_id != "":
			player_data.record_event_completion(current_event.event_id, choice.choice_id)
			print("Recorded choice: ", current_event.event_id, " -> ", choice.choice_id)
	
	# Hide dialogue and choice panel
	if current_dialogue_window:
		current_dialogue_window.queue_free()
		current_dialogue_window = null
	choice_panel.hide()

	# Apply effects immediately
	print("Applying effects now...")
	resolve_effects(choice.choice_effects)
	
	# Check if choice_dialogue exists and has content using has() method
	var has_dialogue = false
	if "choice_dialogue" in choice:
		if choice.choice_dialogue != null and choice.choice_dialogue.size() > 0:
			has_dialogue = true
	
	if has_dialogue:
		print("Showing choice dialogue...")
		current_dialogue_window = dialogue_window.instantiate()
		current_dialogue_window.dialogue_array = choice.choice_dialogue
		current_dialogue_window.dialogueFinished.connect(func(_unused):
			emit_signal("eventChosen")
		)
		self.add_child(current_dialogue_window)
	else:
		print("No choice dialogue")
		emit_signal("eventChosen")

# ============================================
# EFFECT REQUIREMENTS SYSTEM
# ============================================

func check_effect_requirements(effect: EventEffect) -> bool:
	# If no requirements property exists or empty, effect always passes
	if not "requirements" in effect:
		return true
	if effect.requirements == null or effect.requirements.size() == 0:
		return true
	
	# All requirements must be met (AND logic)
	for req in effect.requirements:
		if not _check_requirement(req):
			print("Requirement not met: ", req)
			return false
	
	return true

func _check_requirement(req) -> bool:
	if not "requirement_type" in req:
		return true
	
	match req.requirement_type:
		0: # PLAYER_RESOURCE
			return _check_player_resource_req(req)
		1: # PLANET_COMPARISON
			return _check_planet_comparison_req(req)
		2: # REPUTATION
			return _check_reputation_req(req)
		3: # TIME
			return _check_time_req(req)
		4: # RANDOM_CHANCE
			return _check_random_chance_req(req)
	
	return false

func _check_player_resource_req(req) -> bool:
	var player_value = 0
	
	match req.resource_type:
		"Food":
			player_value = player_data.food
		"Money":
			player_value = player_data.money
		"Weapons":
			player_value = player_data.weapons
		"Luxuries":
			player_value = player_data.luxuries
	
	return _compare_values(player_value, req.compare_value, req.comparison)

func _check_planet_comparison_req(req) -> bool:
	var player_value = 0
	var planet_value = 0
	
	# Get player resource
	match req.resource_type:
		"Food":
			player_value = player_data.food
		"Money":
			player_value = player_data.money
		"Weapons":
			player_value = player_data.weapons
		"Luxuries":
			player_value = player_data.luxuries
	
	# Get planet resource
	if "planet_resource_type" in req:
		match req.planet_resource_type:
			"Weapons":
				planet_value = planet.weapons if "weapons" in planet else 0
			"Food":
				planet_value = planet.food if "food" in planet else 0
	
	print("Player ", req.resource_type, ": ", player_value, " vs Planet ", req.planet_resource_type, ": ", planet_value)
	return _compare_values(player_value, planet_value, req.comparison)

func _check_reputation_req(req) -> bool:
	if not player_data.home_planet_data:
		return false
	
	var rep = player_data.home_planet_data.get_reputation(req.target_planet_name)
	return _compare_values(rep, req.reputation_threshold, req.comparison)

func _check_time_req(req) -> bool:
	var current_day = player_data.time_tracker.current_day
	return _compare_values(current_day, req.day_threshold, req.comparison)

func _check_random_chance_req(req) -> bool:
	var roll = randi_range(1, 100)
	return roll <= req.chance_percentage

func _compare_values(value_a: int, value_b: int, operator: int) -> bool:
	match operator:
		0: # GREATER_THAN
			return value_a > value_b
		1: # LESS_THAN
			return value_a < value_b
		2: # EQUAL_TO
			return value_a == value_b
		3: # GREATER_OR_EQUAL
			return value_a >= value_b
		4: # LESS_OR_EQUAL
			return value_a <= value_b
		5: # NOT_EQUAL
			return value_a != value_b
	
	return false

# ============================================
# END EFFECT REQUIREMENTS SYSTEM
# ============================================

func resolve_effects(effects: Array[EventEffect]) -> void:
	print("=== RESOLVING EFFECTS ===")
	print("Total effects: ", effects.size())
	
	if effects.size() == 0:
		print("No effects to resolve")
		return
	
	# Filter effects by requirements
	var valid_effects = []
	for effect in effects:
		if check_effect_requirements(effect):
			print("Effect passed requirements")
			valid_effects.append(effect)
		else:
			print("Effect failed requirements")
	
	if valid_effects.size() == 0:
		print("No valid effects met requirements!")
		return
	
	var guaranteed_effects = []
	var random_effects = []
	var has_dialogue = false  # Track if any effect has dialogue

	for effect in valid_effects:
		if effect.effect_probability == 0:
			guaranteed_effects.append(effect)
		else:
			random_effects.append(effect)

	# Apply all guaranteed effects
	for effect in guaranteed_effects:
		player_data.player_data_modify(effect.effect_value_token)
		if effect.effect_dialogue.size() > 0:
			print("Effect dialogue detected.")
			has_dialogue = true
			var dlg = dialogue_window.instantiate()
			dlg.dialogue_array = effect.effect_dialogue
			dlg.dialogueFinished.connect(on_effect_dialogue_finished.bind(dlg))
			window.hide()
			self.add_child(dlg)

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
				player_data.player_data_modify(e.effect_value_token)
				if e.effect_dialogue.size() > 0:
					has_dialogue = true
					var dlg = dialogue_window.instantiate()
					dlg.dialogue_array = e.effect_dialogue
					dlg.dialogueFinished.connect(on_effect_dialogue_finished.bind(dlg))
					window.hide()
					self.add_child(dlg)
				break
	
	# If no dialogue was shown, signal completion immediately
	if not has_dialogue:
		print("No effect dialogue, completing event")
		emit_signal("eventChosen")

func on_effect_dialogue_finished(dialogue_window_ref: Control) -> void:
	dialogue_window_ref.queue_free()
	window.visible = true

# ============================================
# BLACKJACK SYSTEM
# ============================================

func _start_blackjack():
	blackjack_active = true
	_create_deck()
	_shuffle_deck()
	
	blackjack_player_hand = []
	blackjack_dealer_hand = []
	
	_deal_card(blackjack_player_hand)
	_deal_card(blackjack_dealer_hand)
	_deal_card(blackjack_player_hand)
	_deal_card(blackjack_dealer_hand)
	
	if _calculate_hand(blackjack_player_hand) == 21:
		_player_blackjack()
		return
	
	_show_blackjack_choices()

func _create_deck():
	blackjack_deck = []
	var suits = ["♠", "♥", "♦", "♣"]
	var ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	var values = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
	
	for suit in suits:
		for i in range(ranks.size()):
			blackjack_deck.append({
				"rank": ranks[i],
				"suit": suit,
				"value": values[i]
			})

func _shuffle_deck():
	blackjack_deck.shuffle()

func _deal_card(hand: Array):
	if blackjack_deck.size() > 0:
		hand.append(blackjack_deck.pop_back())

func _calculate_hand(hand: Array) -> int:
	var total = 0
	var aces = 0
	
	for card in hand:
		total += card.value
		if card.rank == "A":
			aces += 1
	
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	
	return total

func _hand_to_string(hand: Array, hide_second: bool = false) -> String:
	var result = ""
	for i in range(hand.size()):
		if i == 1 and hide_second:
			result += "[Hidden] "
		else:
			result += hand[i].rank + hand[i].suit + " "
	return result.strip_edges()

func _show_blackjack_choices():
	if current_dialogue_window:
		current_dialogue_window.queue_free()
	
	current_dialogue_window = dialogue_window.instantiate()
	
	var state_dlg = DialogueItem.new()
	state_dlg.name = "Dealer"
	
	var player_total = _calculate_hand(blackjack_player_hand)
	state_dlg.dialogue = "Your hand: " + _hand_to_string(blackjack_player_hand) + " (Total: " + str(player_total) + ")\n"
	state_dlg.dialogue += "Dealer's hand: " + _hand_to_string(blackjack_dealer_hand, true) + "\n\nWhat do you do?"
	
	var dlg_array: Array[DialogueItem] = [state_dlg]
	current_dialogue_window.dialogue_array = dlg_array
	
	window.hide()
	self.add_child(current_dialogue_window)
	
	# Show buttons immediately after adding dialogue window
	await get_tree().process_frame
	_create_blackjack_buttons()

func _create_blackjack_buttons():
	# Clear existing buttons in selector
	for child in selector.get_children():
		child.queue_free()
	
	var hit_btn = Button.new()
	hit_btn.text = "Hit"
	hit_btn.theme = load("res://Assets/Theme/button_theme.tres")
	hit_btn.custom_minimum_size = Vector2(200, 50)
	hit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hit_btn.size_flags_vertical = Control.SIZE_SHRINK_END
	hit_btn.pressed.connect(_on_blackjack_hit)
	selector.add_child(hit_btn)
	
	var stand_btn = Button.new()
	stand_btn.text = "Stand"
	stand_btn.theme = load("res://Assets/Theme/button_theme.tres")
	stand_btn.custom_minimum_size = Vector2(200, 50)
	stand_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stand_btn.size_flags_vertical = Control.SIZE_SHRINK_END
	stand_btn.pressed.connect(_on_blackjack_stand)
	selector.add_child(stand_btn)
	
	# Show the choice panel
	choice_panel.get_parent().move_child(choice_panel, -1)
	choice_panel.visible = true

func _on_blackjack_hit():
	# Hide choice panel
	choice_panel.hide()
	
	_deal_card(blackjack_player_hand)
	var player_total = _calculate_hand(blackjack_player_hand)
	
	var result_dlg = DialogueItem.new()
	result_dlg.name = "Dealer"
	result_dlg.dialogue = "You draw: " + blackjack_player_hand[-1].rank + blackjack_player_hand[-1].suit + "\n\n"
	result_dlg.dialogue += "Your hand: " + _hand_to_string(blackjack_player_hand) + " (Total: " + str(player_total) + ")\n\n"
	
	var dlg_array: Array[DialogueItem] = [result_dlg]
	
	if player_total > 21:
		result_dlg.dialogue += "BUST! You lose $" + str(blackjack_bet)
		_show_blackjack_result(dlg_array, false)
	elif player_total == 21:
		result_dlg.dialogue += "You have 21! Auto-standing..."
		_show_blackjack_result(dlg_array, true, true)
	else:
		_show_blackjack_result(dlg_array, true, false)

func _on_blackjack_stand():
	# Hide choice panel
	choice_panel.hide()
	
	_dealer_turn()

func _dealer_turn():
	var dealer_dialogues: Array[DialogueItem] = []
	
	var reveal_dlg = DialogueItem.new()
	reveal_dlg.name = "Dealer"
	reveal_dlg.dialogue = "You stand with " + str(_calculate_hand(blackjack_player_hand)) + ".\n\n"
	reveal_dlg.dialogue += "Dealer reveals: " + _hand_to_string(blackjack_dealer_hand) + " (Total: " + str(_calculate_hand(blackjack_dealer_hand)) + ")"
	dealer_dialogues.append(reveal_dlg)
	
	while _calculate_hand(blackjack_dealer_hand) < 17:
		_deal_card(blackjack_dealer_hand)
		var draw_dlg = DialogueItem.new()
		draw_dlg.name = "Dealer"
		draw_dlg.dialogue = "Dealer draws: " + blackjack_dealer_hand[-1].rank + blackjack_dealer_hand[-1].suit + "\n\n"
		draw_dlg.dialogue += "Dealer's hand: " + _hand_to_string(blackjack_dealer_hand) + " (Total: " + str(_calculate_hand(blackjack_dealer_hand)) + ")"
		dealer_dialogues.append(draw_dlg)
	
	_determine_winner(dealer_dialogues)

func _determine_winner(dealer_dialogues: Array[DialogueItem]):
	var player_total = _calculate_hand(blackjack_player_hand)
	var dealer_total = _calculate_hand(blackjack_dealer_hand)
	
	var result_dlg = DialogueItem.new()
	result_dlg.name = "Dealer"
	
	var payout = 0
	
	if dealer_total > 21:
		result_dlg.dialogue = "\nDealer busts! You win $" + str(blackjack_bet * 2) + "!"
		payout = blackjack_bet * 2
	elif player_total > dealer_total:
		result_dlg.dialogue = "\nYou win $" + str(blackjack_bet * 2) + "!"
		payout = blackjack_bet * 2
	elif dealer_total > player_total:
		result_dlg.dialogue = "\nDealer wins. You lose."
		payout = 0
	else:
		result_dlg.dialogue = "\nPush! Your bet is returned."
		payout = blackjack_bet
	
	dealer_dialogues.append(result_dlg)
	
	if payout > 0:
		var win_cost = EventCost.new()
		win_cost.cost_type = "Money"
		win_cost.cost_value = payout
		player_data.player_data_modify(win_cost)
	
	_show_blackjack_result(dealer_dialogues, false)

func _player_blackjack():
	var dealer_total = _calculate_hand(blackjack_dealer_hand)
	
	var dlg = DialogueItem.new()
	dlg.name = "Dealer"
	dlg.dialogue = "BLACKJACK!\n\nYour hand: " + _hand_to_string(blackjack_player_hand) + "\n"
	dlg.dialogue += "Dealer's hand: " + _hand_to_string(blackjack_dealer_hand) + " (Total: " + str(dealer_total) + ")\n\n"
	
	if dealer_total == 21:
		dlg.dialogue += "Dealer also has blackjack! Push - bet returned."
		var cost = EventCost.new()
		cost.cost_type = "Money"
		cost.cost_value = blackjack_bet
		player_data.player_data_modify(cost)
	else:
		dlg.dialogue += "You win $" + str(int(blackjack_bet * 2.5)) + "!"
		var cost = EventCost.new()
		cost.cost_type = "Money"
		cost.cost_value = int(blackjack_bet * 2.5)
		player_data.player_data_modify(cost)
	
	var dlg_array: Array[DialogueItem] = [dlg]
	_show_blackjack_result(dlg_array, false)

func _show_blackjack_result(dialogues: Array[DialogueItem], continue_game: bool, auto_stand: bool = false):
	if current_dialogue_window:
		current_dialogue_window.queue_free()
	
	current_dialogue_window = dialogue_window.instantiate()
	current_dialogue_window.dialogue_array = dialogues
	
	self.add_child(current_dialogue_window)
	
	# Wait for the dialogue window to be added to the tree
	await get_tree().process_frame
	
	if continue_game and not auto_stand:
		# Show hit/stand buttons again after dialogue
		_create_blackjack_buttons()
	elif auto_stand:
		# Auto-stand: wait for dialogue to finish, then dealer plays
		if current_dialogue_window.has_signal("dialogueFinished"):
			await current_dialogue_window.dialogueFinished
		_dealer_turn()
	else:
		# Game over: wait for dialogue to finish, then clean up
		if current_dialogue_window.has_signal("dialogueFinished"):
			await current_dialogue_window.dialogueFinished
		current_dialogue_window.hide()
		blackjack_active = false
		window.visible = true
		emit_signal("eventChosen")

# ============================================
# END BLACKJACK SYSTEM
# ============================================

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

func _on_leave_button_pressed() -> void:
	self.queue_free()

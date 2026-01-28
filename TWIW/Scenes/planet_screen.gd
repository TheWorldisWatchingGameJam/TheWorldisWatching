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


# Blackjack game state
var blackjack_active: bool = false
var blackjack_deck: Array = []
var blackjack_player_hand: Array = []
var blackjack_dealer_hand: Array = []
var blackjack_bet: int = 50

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

	# Always show dialogue/choices if they exist
	if event.event_dialogue.size() > 0 or event.choices.size() > 0:
		_show_choice_dialogue(event)
	emit_signal("eventChosen")
	# Handle dialogue + choices
	if event.choices.size() > 0:
		_initiate_choice_event(event)
	else:
		resolve_effects(event.event_effects)

func _show_choice_dialogue(event: Event) -> void:
	# Check if this is a blackjack event
	if event.event_dialogue.size() > 0 and event.event_dialogue[0].dialogue == "[BLACKJACK]":
		_start_blackjack()
		return
	
	# Normal dialogue handling

func _initiate_choice_event(event: Event) -> void:
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
		resolve_effects(event.event_effects)
		emit_signal("eventChosen")

func _show_choice_buttons(choices: Array[EventChoice]) -> void:
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
	# Remove choice buttons
	if current_choice_panel:
		current_choice_panel.queue_free()
		current_choice_panel = null

	# Apply effects immediately
	resolve_event_effect(choice.choice_effects)
	
	# If the choice has dialogue, show it AFTER effects
	if choice.choice_dialogue.size() > 0:
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
		emit_signal("eventChosen")

func resolve_event_effect(effects: Array[EventEffect]) -> void:
	print("=== CHOICE SELECTED ===")
	print("Choice: ", choice.choice_text)
	print("Has ", choice.choice_effects.size(), " effects")
	
	current_dialogue_window.queue_free()
	choice_panel.hide()

	# Apply effects immediately
	print("Applying effects now...")
	resolve_effects(choice.choice_effects)
	#
	## If the choice has dialogue, show it AFTER effects
	#if choice.choice_dialogue.size() > 0:
		#print("Showing choice dialogue...")
		#if current_dialogue_window and current_dialogue_window.has_method("set_dialogue"):
			#print("Setting dialogue...")
			#current_dialogue_window.set_dialogue(choice.choice_dialogue)
			#current_dialogue_window.dialogueFinished.connect(func(_unused):
				#emit_signal("eventChosen")
			#, CONNECT_ONE_SHOT)
		#else:
			#if current_dialogue_window:
				#current_dialogue_window.queue_free()
			#
			#current_dialogue_window = dialogue_window.instantiate()
			#current_dialogue_window.dialogue_array = choice.choice_dialogue
			#current_dialogue_window.dialogueFinished.connect(func(_unused):
				#emit_signal("eventChosen")
			#)
			#get_tree().get_root().add_child(current_dialogue_window)
	#else:
		#print("No choice dialogue")
		#emit_signal("eventChosen")

func resolve_effects(effects: Array[EventEffect]) -> void:
	print("=== RESOLVING EFFECTS ===")
	print("Total effects: ", effects.size())
	
	if effects.size() == 0:
		return
	
	var guaranteed_effects = []
	var random_effects = []

	for effect in effects:
		if effect.effect_probability == 0:
			guaranteed_effects.append(effect)
		else:
			random_effects.append(effect)

	# Apply all guaranteed effects
	for effect in guaranteed_effects:
		player_data.player_data_modify(effect.effect_value_token)
		if effect.effect_dialogue.size() > 0:
			print("Choice effect dialogue detected.")
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
					var dlg = dialogue_window.instantiate()
					dlg.dialogue_array = e.effect_dialogue
					dlg.dialogueFinished.connect(on_effect_dialogue_finished.bind(dlg))
					get_tree().get_root().add_child(dlg)
				break

func on_effect_dialogue_finished(dialogue_window: Control) -> void:
	dialogue_window.hide()
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
	get_tree().get_root().add_child(current_dialogue_window)
	
	# Show buttons immediately after adding dialogue window
	await get_tree().process_frame
	_create_blackjack_buttons()

func _create_blackjack_buttons():
	if current_choice_panel:
		current_choice_panel.queue_free()
	
	current_choice_panel = VBoxContainer.new()
	current_choice_panel.name = "BlackjackChoices"
	current_choice_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	current_choice_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	current_choice_panel.add_theme_constant_override("separation", 10)
	
	var hit_btn = Button.new()
	hit_btn.text = "Hit"
	hit_btn.theme = load("res://Assets/Theme/button_theme.tres")
	hit_btn.custom_minimum_size = Vector2(200, 50)
	hit_btn.pressed.connect(_on_blackjack_hit)
	current_choice_panel.add_child(hit_btn)
	
	var stand_btn = Button.new()
	stand_btn.text = "Stand"
	stand_btn.theme = load("res://Assets/Theme/button_theme.tres")
	stand_btn.custom_minimum_size = Vector2(200, 50)
	stand_btn.pressed.connect(_on_blackjack_stand)
	current_choice_panel.add_child(stand_btn)
	
	if current_dialogue_window:
		current_dialogue_window.add_child(current_choice_panel)

func _on_blackjack_hit():
	if current_choice_panel:
		current_choice_panel.queue_free()
		current_choice_panel = null
	
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
	if current_choice_panel:
		current_choice_panel.queue_free()
		current_choice_panel = null
	
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
	
	get_tree().get_root().add_child(current_dialogue_window)
	
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

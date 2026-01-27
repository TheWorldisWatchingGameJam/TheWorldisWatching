
extends Node

func _ready():
	create_event()

func create_event():
	var frez_event = Event.new()
	frez_event.event_name = "Frez Peace Proposal"
	frez_event.event_desc = "Hey! We are about to invite all planets to our council.\nWe are trying to rid this galaxy of violence.\nJoin us and halt your weapon gatherings."
	frez_event.event_button_text = "Respond"
	
	# Dialogue
	frez_event.event_dialogue.clear()
	var dlg1 = DialogueItem.new()
	dlg1.text = "Hey! We are about to invite all planets to our council."
	var dlg2 = DialogueItem.new()
	dlg2.text = "We are trying to rid this galaxy of violence."
	var dlg3 = DialogueItem.new()
	dlg3.text = "Join us and halt your weapon gatherings."
	frez_event.event_dialogue.append(dlg1)
	frez_event.event_dialogue.append(dlg2)
	frez_event.event_dialogue.append(dlg3)
	
	# Choices
	var choices = []
	
	# Accept
	var accept_choice = EventChoice.new()
	accept_choice.choice_text = "Accept"
	var accept_dlg = DialogueItem.new()
	accept_dlg.text = "We use weapons for protection."
	accept_choice.choice_dialogue.clear()
	accept_choice.choice_dialogue.append(accept_dlg)
	
	var effect1 = EventEffect.new()
	effect1.effect_value_token = EventCost.new()
	effect1.effect_value_token.cost_type = "Rep"
	effect1.effect_value_token.cost_value = 5
	effect1.effect_probability = 0
	
	var effect2 = EventEffect.new()
	effect2.effect_value_token = EventCost.new()
	effect2.effect_value_token.cost_type = "Weapons"
	effect2.effect_value_token.cost_value = -9999
	effect2.effect_probability = 0
	
	accept_choice.choice_effects.clear()
	accept_choice.choice_effects.append(effect1)
	accept_choice.choice_effects.append(effect2)
	choices.append(accept_choice)
	
	# Decline
	var decline_choice = EventChoice.new()
	decline_choice.choice_text = "Decline"
	var decline_dlg = DialogueItem.new()
	decline_dlg.text = "You chose not to participate."
	decline_choice.choice_dialogue.clear()
	decline_choice.choice_dialogue.append(decline_dlg)
	
	var decline_effect = EventEffect.new()
	decline_effect.effect_value_token = EventCost.new()
	decline_effect.effect_value_token.cost_type = "Rep"
	decline_effect.effect_value_token.cost_value = -5
	decline_effect.effect_probability = 0
	
	decline_choice.choice_effects.clear()
	decline_choice.choice_effects.append(decline_effect)
	choices.append(decline_choice)
	
	frez_event.choices.clear()
	for choice in choices:
		frez_event.choices.append(choice)
	
	frez_event.cost.clear()
	
	# Save as .tres (Godot 4 syntax)
	var result = ResourceSaver.save(frez_event, "res://Scripts/Resources/Events/peace.tres")
	
	if result == OK:
		print("peace.tres saved successfully!")
	else:
		print("Error saving peace.tres: ", result)

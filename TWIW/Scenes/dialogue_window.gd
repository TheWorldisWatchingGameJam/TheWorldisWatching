extends Control

@export var dialogue_array: Array[DialogueItem] = []
@export var state_machine: MouseItemStateMachine

@onready var name_container = $VBoxContainer/HBoxContainer/NameContainer
@onready var name_label = %NameLabel
@onready var dialogue_label = %DialogueLabel
@onready var character_sprite = $VBoxContainer/CharacterSprite
@onready var selector = %Selector
@onready var choice_panel = %ChoicePanel

signal dialogueClicked
signal dialogueFinished

var current_index: int = 0

 
func set_dialogue(new_dialogue: Array[DialogueItem]) -> void:
	dialogue_array = new_dialogue
	current_index = 0
	
#Call functions of the statemachine when these signals are sent. 
#See statemachine for more info
func _process(delta):
	state_machine.process(delta)

func _on_mouse_entered():
	state_machine.on_mouse_entered()

func _on_mouse_exited():
	state_machine.on_mouse_exited()

func _input(event):
	state_machine.on_input(event)

func _on_gui_input(event):
	print("GUI Input detected.")
	state_machine.on_gui_input(event)

func current_dialogue_has_name() -> bool:
	if dialogue_array[current_index].name: 
		print("Name Detected.")
		return true
	else:
		return false

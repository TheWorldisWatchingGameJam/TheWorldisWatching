extends Control

@export var dialogue_array: Array[DialogueItem] = []

@onready var name_container = $VBoxContainer/HBoxContainer/NameContainer
@onready var name_label = $VBoxContainer/HBoxContainer/NameContainer/NameLabel
@onready var dialogue_label = $VBoxContainer/DialogueContainer/VBoxContainer2/HBoxContainer/DialogueLabel
@onready var character_sprite = $VBoxContainer/CharacterSprite

signal dialogueClicked
signal dialogueFinished

var current_index: int = 0

func _ready() -> void:
	if dialogue_array.is_empty():
		emit_signal("dialogueFinished")
		return
	
	# Start showing the first dialogue
	_show_current_dialogue()
	
	# Connect input once
	connect("dialogueClicked", _on_dialogue_clicked)

func _show_current_dialogue() -> void:
	if current_index >= dialogue_array.size():
		name_container.visible = false
		character_sprite.texture = null
		dialogue_label.text = ""
		emit_signal("dialogueFinished")
		return
	
	var dialogue = dialogue_array[current_index]
	
	if dialogue.name:
		name_label.text = dialogue.name
		name_container.visible = true
	else:
		name_container.visible = false
	
	if dialogue.sprite:
		character_sprite.texture = dialogue.sprite
	else:
		character_sprite.texture = null
	
	dialogue_label.text = dialogue.dialogue

func _on_dialogue_clicked() -> void:
	current_index += 1
	_show_current_dialogue()

func _on_dialogue_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("dialogueClicked")
		# Optional: accept the event so it doesn't propagate
		accept_event()

func set_dialogue(new_dialogue: Array[DialogueItem]) -> void:
	dialogue_array = new_dialogue
	current_index = 0
	_show_current_dialogue()

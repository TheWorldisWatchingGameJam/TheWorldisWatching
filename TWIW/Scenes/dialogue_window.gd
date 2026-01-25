extends Control

@export var dialogue_array: Array[DialogueItem]

@onready var name_container = $VBoxContainer/HBoxContainer/NameContainer
@onready var name_label = $VBoxContainer/HBoxContainer/NameContainer/NameLabel
@onready var dialogue_label = $VBoxContainer/DialogueContainer/VBoxContainer2/HBoxContainer/DialogueLabel
@onready var character_sprite = $VBoxContainer/CharacterSprite

signal dialogue_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for dialogue in dialogue_array:
		if dialogue.name:
			name_label.text = dialogue.name
			name_container.visible = true
		if dialogue.sprite: 
			character_sprite.texture = dialogue.sprite
		dialogue_label.text = dialogue.dialogue 
		await self.dialogue_clicked


func _on_dialogue_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_1"):
		emit_signal("dialogue_clicked")

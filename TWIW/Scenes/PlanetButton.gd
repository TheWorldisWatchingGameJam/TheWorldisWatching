# planet_button.gd
extends Area2D

signal planet_clicked(planet_data)

var planet_data = null

func setup(p_data, pos: Vector2):
	planet_data = p_data
	position = pos
	$Sprite2D.modulate = Color(randf(), randf(), randf())  # Random color for now

func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		planet_clicked.emit(planet_data)

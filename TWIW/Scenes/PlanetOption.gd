extends Area2D

signal planet_clicked(planet_data)

var planet_data = null

func set_planet(p_data):
	planet_data = p_data
	$Label.text = p_data.name
	# TODO: Later you'll set $Sprite2D.texture based on planet_data

func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if planet_data != null:
			planet_clicked.emit(planet_data)

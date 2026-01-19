# main.gd
# ATTACH THIS TO: The Main (Node2D) root node
extends Node2D

@onready var galaxy_manager = $GalaxyManager
@onready var planet_container = $PlanetContainer

var planet_button_scene = preload("res://Scenes/planet_button.tscn")
var current_options = []
var selection_phase = true

func _ready():
	show_planet_selection()

func show_planet_selection():
	# Clear any existing planets
	for child in planet_container.get_children():
		child.queue_free()
	
	# Get 3 random planets
	current_options = galaxy_manager.get_3_random_planets()
	
	# Display them
	for i in range(3):
		var planet_btn = planet_button_scene.instantiate()
		planet_container.add_child(planet_btn)
		
		# Position them in a row
		var pos = Vector2(200 + i * 300, 300)
		planet_btn.setup(current_options[i], pos)
		
		# Connect click signal
		planet_btn.planet_clicked.connect(_on_planet_selected)
		
		# Add label
		var label = Label.new()
		label.text = current_options[i].name
		label.position = Vector2(-50, 80)
		planet_btn.add_child(label)

func _on_planet_selected(planet_data):
	if not selection_phase:
		return
	
	selection_phase = false
	print("Player selected: " + planet_data.name)
	
	# Clear selection screen
	for child in planet_container.get_children():
		child.queue_free()
	
	# Setup galaxy with chosen planet
	galaxy_manager.setup_galaxy(planet_data)
	galaxy_manager.print_map()
	
	# TODO: Show the galaxy map next
	print("Galaxy generated! Check console for map.")

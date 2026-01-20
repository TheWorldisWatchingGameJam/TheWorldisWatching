# main.gd
extends Node2D

@onready var galaxy_manager = $GalaxyManager
@onready var planet_options = [$PlanetOption1, $PlanetOption2, $PlanetOption3]

var selection_phase = true

func _ready():
	show_planet_selection()

func show_planet_selection():
	var options = galaxy_manager.get_3_random_planets()
	
	for i in range(3):
		planet_options[i].set_planet(options[i])
		planet_options[i].planet_clicked.connect(_on_planet_selected)
		planet_options[i].visible = true

func _on_planet_selected(planet_data):
	if not selection_phase:
		return
	
	selection_phase = false
	print("Player selected: " + planet_data.name)
	
	# Hide selection screen
	for option in planet_options:
		option.visible = false
	
	# Setup galaxy
	galaxy_manager.setup_galaxy(planet_data)
	galaxy_manager.print_map()
	
	galaxy_manager.draw_galaxy_random()
	galaxy_manager.draw_connections()
	
	print("Galaxy generated! Check console for map.")

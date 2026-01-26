# main.gd
extends Node2D

@onready var galaxy_manager = $GalaxyManager
@onready var planet_options = [$PlanetOption1, $PlanetOption2, $PlanetOption3]
@onready var election_counter = $ElectionCounter
@onready var choose_label = $Choose

@export var days_until_election: int = 20
@export var player_data: PlayerData


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
	choose_label.hide()
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
	
	galaxy_manager.	generate_graph_and_draw()
	
	_update_election_counter()
	
	print("Galaxy generated! Check console for map.")

func _update_election_counter():
	election_counter.text = "Days until next election: " + str(galaxy_manager.days_until_election)
	election_counter.visible = true


	

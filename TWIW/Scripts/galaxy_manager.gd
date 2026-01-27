extends Node

@export var max_path_length_days: int = 5
@export var PlanetNodeScene: PackedScene
@export var all_planets: Array[PlanetData]
@export var rocket_texture: Texture2D
@export var days_until_election: int = 40
@export var planet_screen_scene: PackedScene
@export var player_data: PlayerData

#camera variables
@onready var camera: Camera2D = get_node("../MapCamera")
@onready var travel_panel: Control = get_node("../UI/PlanetTravelPanel")
@onready var travel_button: Button = get_node("../UI/PlanetTravelPanel/VBoxContainer/TravelButton")

# Variables
var selected_planets: Array[PlanetData] = []
var player_planet: PlanetData = null
var galaxy_graph: Dictionary = {}
var planet_positions: Dictionary = {}
var connections_node: Node2D = null
var planet_lines: Dictionary = {}

var default_zoom := Vector2.ONE
var zoomed_in := false
var current_focused_planet = null

func _ready():
	add_to_group("galaxy_manager")  # Add to group so planets can find it

# Player planet selection
func get_3_random_planets() -> Array:
	var shuffled = all_planets.duplicate()
	shuffled.shuffle()
	return [shuffled[0], shuffled[1], shuffled[2]]

func setup_galaxy(chosen_planet: PlanetData):
	player_planet = chosen_planet
	selected_planets = [player_planet]

	# Assign player home planet
	player_data.home_planet_data = player_planet

	var remaining = all_planets.duplicate()
	remaining.shuffle()
	var count = 0
	for planet in remaining:
		if planet.id != player_planet.id and count < 5:
			selected_planets.append(planet)
			count += 1

	# Initialize player's reputation with selected planets to zero
	player_data.initialize_reputation_values(selected_planets)

	draw_galaxy_random()
	_generate_fully_connected_graph()
	draw_connections()
	print_map()

func draw_galaxy_random():
	for child in get_tree().get_root().get_children():
		if child is Area2D and child.has_method("set_planet"):
			child.queue_free()

	planet_positions.clear()
	var positions: Array = []
	var min_distance = 150
	var max_attempts = 50

	var screen_size = get_viewport().get_visible_rect().size
	var padding = 100

	for planet in selected_planets:
		var pos: Vector2
		var attempt = 0
		while true:
			attempt += 1
			pos = Vector2(
				randf_range(padding, screen_size.x - padding),
				randf_range(padding, screen_size.y - padding)
			)
			var too_close = false
			for existing in positions:
				if pos.distance_to(existing) < min_distance:
					too_close = true
					break
			if not too_close or attempt >= max_attempts:
				break

		positions.append(pos)
		planet_positions[planet.id] = pos

		var planet_node = PlanetNodeScene.instantiate()
		planet_node.set_planet(planet)
		planet_node.position = pos
		planet_node.galaxy_manager = self

		# Connect signal immediately
		planet_node.planet_clicked.connect(_on_planet_clicked)

		if planet.id == player_planet.id:
			planet_node.set_as_home_planet(rocket_texture)

		get_tree().get_root().add_child(planet_node)

func _generate_fully_connected_graph():
	galaxy_graph.clear()
	var DISTANCE_TO_DAYS_FACTOR = 50.0

	for i in range(selected_planets.size()):
		for j in range(i + 1, selected_planets.size()):
			var id1 = selected_planets[i].id
			var id2 = selected_planets[j].id
			var dist = planet_positions[id1].distance_to(planet_positions[id2])
			var days = int(clamp(dist / DISTANCE_TO_DAYS_FACTOR, 1, max_path_length_days))

			if id1 not in galaxy_graph:
				galaxy_graph[id1] = []
			if id2 not in galaxy_graph:
				galaxy_graph[id2] = []

			galaxy_graph[id1].append({"to": id2, "days": days})
			galaxy_graph[id2].append({"to": id1, "days": days})


func draw_connections():
	if connections_node:
		connections_node.queue_free()

	connections_node = Node2D.new()
	connections_node.name = "Connections"
	connections_node.visible = true
	get_tree().get_root().add_child(connections_node)

	planet_lines.clear()

	for planet in selected_planets:
		var from_id = planet.id
		var from_pos = planet_positions[from_id]

		if from_id not in planet_lines:
			planet_lines[from_id] = []

		for conn in galaxy_graph[from_id]:
			var to_id = conn.to
			var to_pos = planet_positions[to_id]

			if from_id < to_id:
				var line = Line2D.new()
				line.width = 4
				line.default_color = Color(0.8, 0.8, 1.0)

				var local_from = connections_node.to_local(from_pos)
				var local_to = connections_node.to_local(to_pos)

				line.add_point(local_from)
				line.add_point(local_to)
				line.visible = false
				connections_node.add_child(line)

				var label = Label.new()
				label.text = str(conn.days) + " days"
				label.modulate = Color(1, 1, 0.8)
				label.visible = false

				var midpoint = (local_from + local_to) / 2
				label.position = midpoint - Vector2(30, 20)  # Offset from line

				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

				connections_node.add_child(label)

				planet_lines[from_id].append({"line": line, "label": label})
				if to_id not in planet_lines:
					planet_lines[to_id] = []
				planet_lines[to_id].append({"line": line, "label": label})

func print_map():
	print("=== Galaxy Map ===")
	for planet in selected_planets:
		print(planet.name + ":")
		for conn in galaxy_graph[planet.id]:
			var target_name = ""
			for p in selected_planets:
				if p.id == conn.to:
					target_name = p.name
			print("  -> " + target_name + " (" + str(conn.days) + " days)")


func get_distance(from_id: String, to_id: String) -> int:
	for conn in galaxy_graph[from_id]:
		if to_id == conn.to:
			print("Distance from ", from_id, " to ", to_id, " is ", conn.days, " days.")
			return conn.days
	return 0

func show_planet_connections(planet_id: String):
	if planet_id in planet_lines:
		for entry in planet_lines[planet_id]:
			entry.line.visible = true
			entry.label.visible = true

func hide_planet_connections(planet_id: String):
	if planet_id in planet_lines:
		for entry in planet_lines[planet_id]:
			entry.line.visible = false
			entry.label.visible = false

# Called when planet is clicked
func _on_planet_clicked(planet_node):
	zoom_to_planet(planet_node)

func zoom_to_planet(planet_node: Node2D):
	if camera:
		camera.global_position = planet_node.global_position
		camera.zoom = Vector2(2.0, 2.0)  # Zoom in closer
		zoomed_in = true
		current_focused_planet = planet_node
		show_travel_panel(planet_node.planet_data)

func reset_zoom():
	if camera:
		# Get the center of the viewport/screen
		var screen_center = get_viewport().get_visible_rect().size / 2
		camera.global_position = screen_center
		camera.zoom = default_zoom
		zoomed_in = false
		current_focused_planet = null
		hide_travel_panel()

func show_travel_panel(planet_data = null):
	if travel_panel:
		travel_panel.visible = true
		if planet_data and travel_button:
			travel_button.text = "Travel to " + planet_data.name

func hide_travel_panel():
	if travel_panel:
		travel_panel.visible = false

func _on_cancel_button_pressed():
	reset_zoom()


func _on_travel_button_pressed():
	if current_focused_planet and current_focused_planet.planet_data:
		# Find the full PlanetData from all_planets array
		var target_planet: PlanetData = null
		for planet in all_planets:
			if planet.id == current_focused_planet.planet_data.id:
				target_planet = planet
				break
		
		if target_planet:
			var planet_screen = planet_screen_scene.instantiate()
			planet_screen.planet = target_planet  # Use the full .tres resource
			planet_screen.home_planet_data = player_planet
			planet_screen.player_data = player_data
			update_player_time(target_planet.id)
			get_tree().get_root().add_child(planet_screen)
			hide_travel_panel()
			reset_zoom()
		else:
			print("Error: Could not find planet in all_planets array")


func update_player_time(to_planet: String) -> void:
	player_data.time_tracker.current_day += get_distance(player_data.home_planet_data.id, to_planet)
	print("Current Day: ", player_data.time_tracker.current_day)
	print("Days left to next election: ", str(days_until_election - player_data.time_tracker.current_day))

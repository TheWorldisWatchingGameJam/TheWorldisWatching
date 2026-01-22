extends Node

@export var max_path_length_days: int = 5
@export var PlanetNodeScene: PackedScene  # Assign your PlanetNode.tscn here
@export var all_planets: Array[PlanetData]
@export var rocket_texture: Texture2D
@export var days_until_election: int = 20  # editable in inspector

# Variables
var selected_planets: Array[PlanetData] = []
var player_planet: PlanetData = null
var galaxy_graph: Dictionary = {}       # planet_id -> [{to, days}]
var planet_positions: Dictionary = {}   # planet_id -> Vector2
var connections_node: Node2D = null
var planet_lines: Dictionary = {}       # planet_id -> Array of Line2D

# Player planet selection
func get_3_random_planets() -> Array:
	var shuffled = all_planets.duplicate()
	shuffled.shuffle()
	return [shuffled[0], shuffled[1], shuffled[2]]

func setup_galaxy(chosen_planet: PlanetData):
	player_planet = chosen_planet
	selected_planets = [player_planet]

	# Pick 5 random planets from remaining
	var remaining = all_planets.duplicate()
	remaining.shuffle()
	var count = 0
	for planet in remaining:
		if planet.id != player_planet.id and count < 5:
			selected_planets.append(planet)
			count += 1

	# Draw planets first (positions needed for distances)
	draw_galaxy_random()

	# Then generate fully connected graph
	_generate_fully_connected_graph()

	# Draw visual connections
	draw_connections()

	print_map()

# Draw planets randomly in viewport
func draw_galaxy_random():
	# Remove old planets
	for child in get_tree().get_root().get_children():
		if child is Area2D and child.has_method("set_planet"):
			child.queue_free()

	planet_positions.clear()
	var positions: Array = []
	var min_distance = 150
	var max_attempts = 50

	# Get viewport size
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
			# Avoid overlap
			var too_close = false
			for existing in positions:
				if pos.distance_to(existing) < min_distance:
					too_close = true
					break
			if not too_close or attempt >= max_attempts:
				break

		positions.append(pos)
		planet_positions[planet.id] = pos

		# Instantiate PlanetNode
		var planet_node = PlanetNodeScene.instantiate()
		planet_node.set_planet(planet)
		planet_node.position = pos
		planet_node.galaxy_manager = self

		# 🚀 If this is the home planet, attach rocket
		if planet.id == player_planet.id:
			planet_node.set_as_home_planet(rocket_texture)

		get_tree().get_root().add_child(planet_node)

# Fully connected graph with distance-based travel days
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

# Draw connections visually
func draw_connections():
	if connections_node:
		connections_node.queue_free()

	connections_node = Node2D.new()
	connections_node.name = "Connections"
	connections_node.visible = true  # the Node2D itself can stay visible
	get_tree().get_root().add_child(connections_node)

	planet_lines.clear()

	for planet in selected_planets:
		var from_id = planet.id
		var from_pos = planet_positions[from_id]

		planet_lines[from_id] = []

		for conn in galaxy_graph[from_id]:
			var to_id = conn.to
			var to_pos = planet_positions[to_id]

			if from_id < to_id:  # draw each line only once
				var line = Line2D.new()
				line.width = 4
				line.default_color = Color(0.8, 0.8, 1.0)
				# convert global positions to local positions relative to connections_node
				line.add_point(connections_node.to_local(from_pos))
				line.add_point(connections_node.to_local(to_pos))
				line.visible = false  # hide initially
				connections_node.add_child(line)
				planet_lines[from_id].append(line)



# Debug print
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

func show_planet_connections(planet_id: String):
	if planet_id in planet_lines:
		for line in planet_lines[planet_id]:
			line.visible = true

func hide_planet_connections(planet_id: String):
	if planet_id in planet_lines:
		for line in planet_lines[planet_id]:
			line.visible = false

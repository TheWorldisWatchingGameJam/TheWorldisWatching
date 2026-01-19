# galaxy_manager.gd
# ATTACH THIS TO: A Node in your main scene called "GalaxyManager"
extends Node

@export var max_path_length_days: int = 20

# Planet data structure as inner class
class PlanetData:
	var id: String
	var name: String
	
	func _init(p_id: String, p_name: String):
		id = p_id
		name = p_name

var all_planets: Array = []  # Array of PlanetData
var selected_planets: Array = []  # 6 planets total (player + 5)
var player_planet = null  # PlanetData
var galaxy_graph: Dictionary = {}  # planet_id -> [{to: planet_id, days: int}]

func _ready():
	_initialize_planets()

func _initialize_planets():
	all_planets = [
		PlanetData.new("planet_1", "Planet Alpha"),
		PlanetData.new("planet_2", "Planet Beta"),
		PlanetData.new("planet_3", "Planet Gamma"),
		PlanetData.new("planet_4", "Planet Delta"),
		PlanetData.new("planet_5", "Planet Epsilon"),
		PlanetData.new("planet_6", "Planet Zeta"),
		PlanetData.new("planet_7", "Planet Eta"),
		PlanetData.new("planet_8", "Planet Theta"),
	]

# Get 3 random planets for player choice
func get_3_random_planets() -> Array:
	var shuffled = all_planets.duplicate()
	shuffled.shuffle()
	return [shuffled[0], shuffled[1], shuffled[2]]

# Call this after player clicks and selects their planet
func setup_galaxy(chosen_planet):
	player_planet = chosen_planet
	selected_planets = [player_planet]
	
	# Pick 5 random planets from ALL planets (chosen planet returns to pool first)
	var remaining = all_planets.duplicate()
	remaining.shuffle()
	
	var count = 0
	for planet in remaining:
		if planet.id != player_planet.id and count < 5:
			selected_planets.append(planet)
			count += 1
	
	_generate_map()

func _generate_map():
	galaxy_graph.clear()
	
	# Initialize graph
	for planet in selected_planets:
		galaxy_graph[planet.id] = []
	
	# Connect all planets (minimum spanning tree)
	var connected = [selected_planets[0].id]
	var unconnected = []
	for i in range(1, selected_planets.size()):
		unconnected.append(selected_planets[i].id)
	
	while unconnected.size() > 0:
		var from_id = connected[randi() % connected.size()]
		var to_id = unconnected.pop_back()
		var days = randi_range(1, 7)
		
		galaxy_graph[from_id].append({"to": to_id, "days": days})
		galaxy_graph[to_id].append({"to": from_id, "days": days})
		
		connected.append(to_id)
	
	# Validate using Dijkstra
	if not _validate_max_distance():
		print("Map too large, regenerating...")
		_generate_map()

# Dijkstra's algorithm
func dijkstra(start_id: String, end_id: String) -> int:
	var distances = {}
	var unvisited = []
	
	for planet in selected_planets:
		distances[planet.id] = 999999
		unvisited.append(planet.id)
	
	distances[start_id] = 0
	
	while unvisited.size() > 0:
		var current = null
		var min_dist = 999999
		for node in unvisited:
			if distances[node] < min_dist:
				min_dist = distances[node]
				current = node
		
		if current == null or current == end_id:
			break
		
		unvisited.erase(current)
		
		for connection in galaxy_graph[current]:
			var neighbor = connection.to
			if neighbor in unvisited:
				var alt = distances[current] + connection.days
				if alt < distances[neighbor]:
					distances[neighbor] = alt
	
	return distances[end_id]

func _validate_max_distance() -> bool:
	for i in range(selected_planets.size()):
		for j in range(i + 1, selected_planets.size()):
			var dist = dijkstra(selected_planets[i].id, selected_planets[j].id)
			if dist > max_path_length_days:
				return false
	return true

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

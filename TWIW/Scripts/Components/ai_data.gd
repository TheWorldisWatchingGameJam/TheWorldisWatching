extends Resource
class_name AIData

@export var daily_rep_min: int = -2
@export var daily_rep_max: int = 5

@export var min_rep: int = -500
@export var max_rep: int = 500

@export var starting_rep: int = 0


var leader_rep: Dictionary = {}


# Call once after planets are finalized
# Call once after planets are finalized
func initialize_leaders(planets: Array) -> void:
	leader_rep.clear()
	for planet in planets:
		if planet == null:
			continue
		
		# PlanetData always has a name, no need to check
		var planet_name: String = planet.name
		leader_rep[planet_name] = starting_rep
	
	print("Leader reps initialized: ", leader_rep)

# DAILY UPDATE
func apply_daily_rep_change() -> void:
	for planet_name in leader_rep.keys():
		var delta := randi_range(daily_rep_min, daily_rep_max)
		leader_rep[planet_name] = clamp(
			leader_rep[planet_name] + delta,
			min_rep,
			max_rep
		)


# DIRECT MODIFICATION (EVENTS)
func modify_rep(planet_name: String, amount: int) -> void:
	if not leader_rep.has(planet_name):
		push_warning("Planet not found in leader_rep: " + planet_name)
		return

	leader_rep[planet_name] = clamp(
		leader_rep[planet_name] + amount,
		min_rep,
		max_rep
	)

func get_rep(planet_name: String) -> int:
	return leader_rep.get(planet_name, 0)

func get_all_reps() -> Dictionary:
	return leader_rep.duplicate()

func set_rep(planet_name: String, value: int) -> void:
	if not leader_rep.has(planet_name):
		return

	leader_rep[planet_name] = clamp(value, min_rep, max_rep)

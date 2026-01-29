extends Resource
class_name EventEffectRequirement

enum RequirementType {
	PLAYER_RESOURCE,     # Check player's resources (Food, Money, etc.)
	PLANET_COMPARISON,   # Compare to planet's stat
	REPUTATION,          # Check reputation with a planet
	TIME,                # Check current day
	RANDOM_CHANCE        # Random probability (for branching outcomes)
}

enum ComparisonOperator {
	GREATER_THAN,
	LESS_THAN,
	EQUAL_TO,
	GREATER_OR_EQUAL,
	LESS_OR_EQUAL,
	NOT_EQUAL
}

@export var requirement_type: RequirementType = RequirementType.PLAYER_RESOURCE
@export var comparison: ComparisonOperator = ComparisonOperator.GREATER_THAN

# For PLAYER_RESOURCE checks
@export var resource_type: String = "Weapons"  # "Food", "Money", "Weapons", "Luxuries"
@export var compare_value: int = 0

# For PLANET_COMPARISON (compare player resource to planet's resource)
@export var planet_resource_type: String = "Weapons"  # What resource of the planet to compare against

# For REPUTATION checks
@export var target_planet_name: String = ""
@export var reputation_threshold: int = 0

# For TIME checks
@export var day_threshold: int = 0

# For RANDOM_CHANCE
@export_range(0, 100) var chance_percentage: int = 50

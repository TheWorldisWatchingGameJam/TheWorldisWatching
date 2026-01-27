extends Resource

class_name TradeRoute

@export var from_planet: PlanetData #should be home planet
@export var to_planet: PlanetData

@export var import: EventCost
@export var export: EventCost

@export var max_duration: int
@export var current_lifetime: int

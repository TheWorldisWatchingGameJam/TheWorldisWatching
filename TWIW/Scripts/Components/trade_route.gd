extends Resource

class_name TradeRoute

@export var from_planet: PlanetData #should be home planet
@export var to_planet: PlanetData

@export var import: EventCost #what player gets
@export var export: EventCost #what player gives

@export var executed := false
@export var max_duration: int = 10
@export var current_lifetime: int

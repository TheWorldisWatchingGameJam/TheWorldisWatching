@tool
extends Resource

class_name PlayerData

signal playerDataChanged

var _food := 0
var _luxuries := 0
var _weapons := 0
var _money := 0

@export_range(0, 999999, 1)
var food: int:
	get: return _food
	set(value):
		_food = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var luxuries: int:
	get: return _luxuries
	set(value):
		_luxuries = value
		emit_signal("playerDataChanged")

@export_range(0, 999999, 1)
var weapons: int:
	get: return _weapons
	set(value):
		_weapons = value
		emit_signal("playerDataChanged")


@export_range(0, 999999, 1)
var money: int:
	get: return _money
	set(value):
		_money = value
		emit_signal("playerDataChanged")

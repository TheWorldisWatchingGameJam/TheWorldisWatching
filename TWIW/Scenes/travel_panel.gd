extends Control

@export var player: PlayerData

@onready var animator = $AnimationPlayer
@onready var name_label = %NameLabel
@onready var leader_label = %LeaderLabel
@onready var export_label = %ExportLabel
@onready var relevance_label = %RelevanceLabel
@onready var reputation_label = %ReputationLabel
@onready var planet_sprite = %PlanetSprite

signal travelButtonPressed
signal cancelButtonPressed

func open_travel_panel(planet: PlanetData) -> void:
	name_label.text = str("Planet Name: ", planet.name)
	leader_label.text = str("Leader: ", planet.leader_name)
	relevance_label.text = str("Current Relevance: ", player.get_relevance(planet.name))
	reputation_label.text = str("Current Relevance: ", player.get_reputation(planet.name))
	export_label.text = str("Major Export: ", planet.major_export)
	planet_sprite.texture = planet.sprite
	animator.play("open")

func _on_cancel_button_pressed() -> void:
	emit_signal("cancelButtonPressed")
	self.hide()


func _on_travel_button_pressed() -> void:
	emit_signal("travelButtonPressed")

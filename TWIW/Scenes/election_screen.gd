extends Control

@export var selected_planets: Array[PlanetData]
@export var player_data: PlayerData

@onready var contestant_card_container = %ContestantCardContainer

var contestant_cards: Array[PanelContainer]
var ai_data: AIData

signal playerLost
signal cardAnimationFinished

func update_election_screen(data: AIData) -> void:
	await ready
	#Reset contestant cards
	contestant_cards.clear()
	ai_data = data
	
	for planet in selected_planets:
		if planet.voted_off:
			continue
		if planet == player_data.home_planet_data:
			var new_card = load("res://Scenes/contestant_card.tscn").instantiate()
			new_card.set_contestant_card(null, "You", player_data.total_rep, player_data.home_planet_data.name)
			contestant_card_container.add_child(new_card)
			contestant_cards.append(new_card)
			continue
		var new_card = load("res://Scenes/contestant_card.tscn").instantiate()
		new_card.set_contestant_card(planet.leader_sprite, planet.leader_name, ai_data.get_rep(planet.name), planet.name)
		contestant_card_container.add_child(new_card)
		contestant_cards.append(new_card)

func run_vote() -> void:
	var losing_planet = ai_data.get_lowest_rep()
	for planet in selected_planets:
		if planet.name == losing_planet:
			#Check if player lost
			if player_data.total_rep < ai_data.get_rep(losing_planet):
				emit_signal("playerLost")
				return 

			planet.voted_off = true
			ai_data.remove_planet_from_race(planet.name)

	for contestant_card in contestant_card_container.get_children():
		if contestant_card.representing_planet == losing_planet:
			contestant_card.play_voted_off_animation()
			await contestant_card.animationFinished
			emit_signal("cardAnimationFinished")



func _on_next_button_pressed() -> void:
	self.queue_free()

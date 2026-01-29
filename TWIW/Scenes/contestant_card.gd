extends PanelContainer

class_name ContestantCard

@onready var texture_rect = %ContestantTextRect
@onready var name_label = %NameLabel
@onready var rep_label = %RepLabel
@onready var voted_off_label = %VotedOffLabel

var representing_planet: String

signal animationFinished

func set_contestant_card(sprite: Texture2D, contestant_name: String, contestant_rep: int, planet_name: String) -> void:
	await ready
	representing_planet = planet_name
	texture_rect.texture = sprite
	name_label.text = contestant_name
	rep_label.text = str("Current Total Rep: ", contestant_rep)


func play_voted_off_animation()-> void:
	var tween = get_tree().create_tween()
	tween.tween_property(texture_rect, "self_modulate", Color(1, 1, 1, 0), 0.7)
	await tween.tween_interval(0.4)
	tween.tween_property(name_label, "self_modulate", Color(1, 1, 1, 0), 0.7)
	await tween.tween_interval(0.4)
	tween.tween_property(rep_label, "self_modulate", Color(1, 1, 1, 0), 0.7)
	await tween.tween_interval(0.4)
	tween.tween_callback(display_voted_off_label)



func display_voted_off_label() -> void:
	#First hide children
	for child in $HBoxContainer.get_children():
		if not child == voted_off_label:
			child.hide()
	
	#Then display label
	voted_off_label.self_modulate = Color(1, 1, 1, 0)
	voted_off_label.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(voted_off_label, "self_modulate", Color(1, 1, 1, 1), 0.7)
	emit_signal("animationFinished")

extends Control


@onready var main = load("res://Scenes/main.tscn").instantiate()
@onready var credits = $TextureRect/CreditsContainer
@onready var menu = $TextureRect/MenuContainer



func _on_button_pressed() -> void:
	get_tree().get_root().add_child(main)
	self.queue_free()


func _on_credits_button_pressed() -> void:
	credits.visible = true
	menu.visible = false


func _on_credits_close_button_pressed() -> void:
	menu.visible = true 
	credits.visible = false

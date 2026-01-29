extends PanelContainer


@onready var try_again_button = $HBoxContainer/VBoxContainer/Button

signal tryAgainButtonPressed

func _on_button_pressed() -> void:
	emit_signal("tryAgainButtonPressed")

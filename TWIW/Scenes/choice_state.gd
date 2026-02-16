extends MouseItemState


func enter() -> void:
	var current_dialogue_item = scene.dialogue_array[scene.current_index]
	print("ChoiceState Entered.")
	animator.play("open_choice_panel")
	
	for choice in current_dialogue_item.choices:
		var btn = Button.new()
		btn.text = choice.choice_text
		btn.theme = load("res://Assets/Theme/button_theme.tres")
		btn.custom_minimum_size = Vector2(btn.text.length(), 0) + Vector2(400, 50)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_END
		btn.pressed.connect(_on_choice_selected.bind(choice))
		scene.selector.add_child(btn)
	
	scene.move_child(scene.choice_panel, -1)


func _on_choice_selected(choice: EventChoice) -> void:
	pass

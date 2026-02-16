extends MouseItemState

func enter() -> void:
	scene.dialogue_label.visible_characters = -1
	
func on_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("mouse_1"):
		scene.accept_event()
		if scene.dialogue_label.visible_characters == -1:
			if scene.dialogue_array[scene.current_index].has_choices():
				transition.emit(self, "ChoiceState")
			scene.current_index += 1
			print("Current Index: ", scene.current_index)
			if scene.current_index >= (scene.dialogue_array.size()):
					transition.emit(self, "FinishedState")
					return
			transition.emit(self, "PrintState")

func exit() -> void:
	print("PressedState exiting.")

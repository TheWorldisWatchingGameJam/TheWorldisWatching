extends MouseItemState


var interrupted = false

func enter() -> void:
	print("PrintState Entered.")
	scene.dialogue_label.visible_characters = 0
	var current_dialogue_item = scene.dialogue_array[scene.current_index]
	interrupted = false
	
	if current_dialogue_item.has_name():
		if current_dialogue_item.name != scene.name_label.text:
			scene.name_label.text = current_dialogue_item.name
			animator.play("print_name")

	scene.dialogue_label.text = current_dialogue_item.dialogue
	for char in scene.dialogue_label.text.length():
		if interrupted:
			return
		scene.dialogue_label.visible_characters += 1
		await get_tree().create_timer(0.07).timeout
		
func on_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("mouse_1"):
		transition.emit(self, "PressedState")
		scene.accept_event()

func exit() -> void:
	interrupted = true

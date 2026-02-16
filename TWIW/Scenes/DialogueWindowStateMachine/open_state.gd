extends MouseItemState


func enter() -> void:
	print("OpenState Entered.")
	play_animations()


func play_animations() -> void:
	open_dialogue_animation()
	await animator.animation_finished
	if scene.current_dialogue_has_name(): 
		open_name_animation()
		await animator.animation_finished
	transition.emit(self, "PrintState")


func open_name_animation() -> void:
	animator.play("open_name")


func open_dialogue_animation() -> void:
	animator.play("open_dialogue")

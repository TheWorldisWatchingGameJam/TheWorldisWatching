extends MouseItemState

func enter() -> void:
	print("FinishedState Entered.")
	scene.queue_free()

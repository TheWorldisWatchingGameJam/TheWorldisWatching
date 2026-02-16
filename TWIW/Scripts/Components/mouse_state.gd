class_name MouseItemState
extends Node

signal transition(from: MouseItemState, to: MouseItemState)

var scene: Control
var animator: AnimationPlayer

func enter() -> void:
	pass

func exit() -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func process(delta) -> void:
	pass

func on_area_entered(area) -> void:
	pass

func on_area_exited(area) -> void:
	pass

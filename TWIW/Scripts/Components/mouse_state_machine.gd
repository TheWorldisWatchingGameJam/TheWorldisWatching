class_name MouseItemStateMachine
extends Node

@export var initialState: MouseItemState
@export var scene: Control
@export var animator: AnimationPlayer

#Track current state and initialize empty "states" dictionary
var currentState : MouseItemState
var states : Dictionary = {}

func _ready():
	# Ready is called from the bottom-up, so must wait for scene to be ready
	if not scene.is_node_ready():
		await scene.ready
#Add child nodes that are MouseItemStates to the dictionary
	for child in get_children():
		if child is MouseItemState:
			states[child.name.to_lower()] = child
			child.transition.connect(on_state_transition)
			child.scene = scene
			child.animator = animator
#Apply initial state
	if initialState:
		initialState.enter()
		currentState = initialState

#Call corresponding functions of current state when the following functions of the state machine are called
func on_input(event: InputEvent) -> void:
	currentState.on_input(event)

func on_gui_input(event: InputEvent) -> void:
	currentState.on_gui_input(event)
	
func on_mouse_entered() -> void:
	currentState.on_mouse_entered()

func on_mouse_exited() -> void:
	currentState.on_mouse_exited()

func process(delta) -> void:
	currentState.process(delta)
	
func on_area_entered(area) -> void:
	currentState.on_area_entered(area)
	
func on_area_exited(area) -> void:
	currentState.on_area_exited(area)

func on_state_transition(currentStateScript, newStateName):
	#Check if the state calling transition is the current state, return if so
	if currentStateScript != currentState:
		print("currentStateScript not matching currentState.")
		return
	#Check for new state name in dictionary 
	var newState = states.get(newStateName.to_lower())
	if !newState:
		print("No transition named %s", newStateName.to_lower())
		return
	#Check if object is in a state, if so, call exit on current state
	if currentState:
		currentState.exit()
	#Call enter on state we are transitioning to and update current_state tracker
	newState.enter()
	currentState = newState

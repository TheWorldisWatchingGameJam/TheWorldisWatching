extends Area2D

signal planet_clicked(planet_node: Area2D)  # Changed to emit the node itself
signal player_en_route(planet_node: Area2D) 

@export var planet_sprite: Sprite2D
@export var collision: CollisionShape2D
@export var rocket_sprite: Sprite2D

var galaxy_manager: Node = null
var planet_data = null
const TARGET_SIZE := Vector2(200, 200)

func set_planet(p_data):
	planet_data = p_data
	$Label.text = p_data.name
	planet_sprite.texture = p_data.sprite
	_resize_sprite_and_collision()

func set_as_rocket_location(rocket_texture: Texture2D):
	rocket_sprite.texture = rocket_texture
	rocket_sprite.centered = true
	rocket_sprite.visible = true
	rocket_sprite.scale = Vector2(0.5, 0.5)
	
	var planet_radius = TARGET_SIZE.y * 0.5
	var rocket_half_height = rocket_sprite.texture.get_size().y * rocket_sprite.scale.y * 0.5
	rocket_sprite.position = Vector2(
		0,
		-planet_radius - rocket_half_height + 35
	)

func remove_as_rocket_location():
	rocket_sprite.texture = null
	rocket_sprite.visible = false

func _ready():
	input_pickable = true
	monitorable = true
	monitoring = true
	
	input_event.connect(_on_input_event)
	

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		planet_clicked.emit(self)  # Emit self (the planet node)

func _resize_sprite_and_collision():
	if not planet_sprite.texture:
		return
	
	var tex_size = planet_sprite.texture.get_size()
	var scale_factor = TARGET_SIZE / tex_size
	var uniform_scale = min(scale_factor.x, scale_factor.y)
	planet_sprite.scale = Vector2.ONE * uniform_scale
	
	collision.disabled = false
	
	if collision.shape is CircleShape2D:
		collision.shape.radius = TARGET_SIZE.x * 0.5
	elif collision.shape is RectangleShape2D:
		collision.shape.size = TARGET_SIZE
	
	

func _on_mouse_entered():
	if planet_data != null and galaxy_manager != null:
		print("Mouse Entered Planet Node")
		planet_sprite.self_modulate = Color(0.8, 0.8, 0.8)
		galaxy_manager.show_planet_connections(planet_data.id)

func _on_mouse_exited():
	if planet_data != null and galaxy_manager != null:
		print("Mouse Exited Planet Node")
		planet_sprite.self_modulate = Color(1, 1, 1)
		galaxy_manager.hide_planet_connections(planet_data.id)

func draw_select_circle(radius: float, segments: int = 100) -> void:
	$SelectCircle.clear_points()
	
	for i in segments + 1:
		var angle = TAU * i / segments
		var point = Vector2(cos(angle), sin(angle)) * radius
		$SelectCircle.add_point(point)
		
func draw_travel_panel_lines(travel_panel_pos: Vector2):
	var viewport_size = get_viewport_rect().size
	var center_x = viewport_size.x / 2

	$TravelPanelLine1.clear_points()
	$TravelPanelLine2.clear_points()
	
	var select_circle_top = Vector2.ZERO - Vector2(0, (collision.shape.size.y/1.5))
	var select_circle_bottom = Vector2.ZERO + Vector2(0, (collision.shape.size.y/1.5))
	$TravelPanelLine1.add_point(select_circle_top)
	$TravelPanelLine2.add_point(select_circle_bottom)

	var travel_panel_top = travel_panel_pos - Vector2(0, 350)
	var travel_panel_bottom = travel_panel_pos + Vector2(0, 350)
	$TravelPanelLine1.add_point(to_local(travel_panel_top))
	$TravelPanelLine2.add_point(to_local(travel_panel_bottom))
	
func deselect() -> void:
	$SelectCircle.clear_points()
	$TravelPanelLine1.clear_points()
	$TravelPanelLine2.clear_points()

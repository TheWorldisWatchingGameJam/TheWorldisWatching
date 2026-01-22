extends Area2D

signal planet_clicked(planet_data)

@export var planet_sprite: Sprite2D
@export var collision: CollisionShape2D
@export var rocket_sprite: Sprite2D

var galaxy_manager: Node = null
var planet_data = null
const TARGET_SIZE := Vector2(128, 128)

func set_planet(p_data):
	planet_data = p_data
	$Label.text = p_data.name
	planet_sprite.texture = p_data.sprite
	_resize_sprite_and_collision()

func set_as_home_planet(rocket_texture: Texture2D):
	rocket_sprite.texture = rocket_texture
	rocket_sprite.centered = true
	rocket_sprite.visible = true
	# Place rocket on top of the planet
	var planet_radius = TARGET_SIZE.y * 0.5
	var rocket_half_height = rocket_sprite.texture.get_size().y * rocket_sprite.scale.y * 0.5
	rocket_sprite.position = Vector2(
		0,
		-planet_radius - rocket_half_height + 5
	)

func _ready():
	# Enable mouse detection for Area2D
	input_pickable = true
	monitorable = true
	monitoring = true
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if planet_data:
			print("CLICKED planet:", planet_data.name)
			planet_clicked.emit(planet_data)

func _resize_sprite_and_collision():
	if not planet_sprite.texture:
		return

	var tex_size = planet_sprite.texture.get_size()
	var scale_factor = TARGET_SIZE / tex_size
	var uniform_scale = min(scale_factor.x, scale_factor.y)
	planet_sprite.scale = Vector2.ONE * uniform_scale

	# Update collision shape to match scaled sprite
	if collision.shape is RectangleShape2D:
		collision.shape.extents = TARGET_SIZE * 0.5  # half-size for RectangleShape2D
	elif collision.shape is CircleShape2D:
		collision.shape.radius = (TARGET_SIZE.x * 0.5) * uniform_scale


# Show planets on hover
# Hover detection
func _on_mouse_entered():
	if planet_data != null and galaxy_manager != null:
		print("HOVER ENTER planet:", planet_data.name)
		galaxy_manager.show_planet_connections(planet_data.id)

func _on_mouse_exited():
	if planet_data != null and galaxy_manager != null:
		print("HOVER EXIT planet:", planet_data.name)
		galaxy_manager.hide_planet_connections(planet_data.id)

extends Area2D

signal planet_clicked(planet_node)  # Changed to emit the node itself

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

func set_as_home_planet(rocket_texture: Texture2D):
	rocket_sprite.texture = rocket_texture
	rocket_sprite.centered = true
	rocket_sprite.visible = true
	
	var planet_radius = TARGET_SIZE.y * 0.5
	var rocket_half_height = rocket_sprite.texture.get_size().y * rocket_sprite.scale.y * 0.5
	rocket_sprite.position = Vector2(
		0,
		-planet_radius - rocket_half_height + 5
	)

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
		galaxy_manager.show_planet_connections(planet_data.id)

func _on_mouse_exited():
	if planet_data != null and galaxy_manager != null:
		galaxy_manager.hide_planet_connections(planet_data.id)

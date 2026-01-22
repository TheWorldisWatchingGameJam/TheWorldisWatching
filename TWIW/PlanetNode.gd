extends Area2D

signal planet_clicked(planet_data)

@export var planet_sprite: Sprite2D
@export var collision: CollisionShape2D
@export var rocket_sprite: Sprite2D

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
		-planet_radius + rocket_half_height
	)
	rocket_sprite.position.y += 5   # push it down slightly



func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)
# Connect hover signals
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if planet_data:
			planet_clicked.emit(planet_data)
			print("CLICKED planet:", planet_data.name)  # ✅ Debug click
			planet_clicked.emit(planet_data)

func _resize_sprite_and_collision():
	if planet_sprite.texture == null:
		return

	var tex_size = planet_sprite.texture.get_size()
	var scale_factor = TARGET_SIZE / tex_size
	var uniform_scale = min(scale_factor.x, scale_factor.y)

	planet_sprite.scale = Vector2.ONE * uniform_scale

	# Make sure collision matches planet
	if collision.shape is RectangleShape2D:
		collision.shape.size = TARGET_SIZE
		collision.disabled = false  # ensure it detects mouse
	elif collision.shape is CircleShape2D:
		collision.radius = TARGET_SIZE.x * 0.5
		collision.disabled = false


#show planets on hover
func _on_mouse_entered():
	print("HOVER ENTER:", planet_data.name)  # ✅ Debug hover
	if planet_data and get_parent().has_method("show_planet_connections"):
		get_parent().show_planet_connections(planet_data.id)

func _on_mouse_exited():
	print("HOVER EXIT:", planet_data.name)  # ✅ Debug hover exit
	if planet_data and get_parent().has_method("hide_planet_connections"):
		get_parent().hide_planet_connections(planet_data.id)

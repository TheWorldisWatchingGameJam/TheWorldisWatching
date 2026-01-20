extends Area2D

signal planet_clicked(planet_data)

# Export nodes so you can assign them in the editor
@export var sprite: Sprite2D
@export var collision: CollisionShape2D
@export var label: Label

var planet_data = null

# Target size in pixels for the planet sprite
const TARGET_SIZE := Vector2(128, 128)

# -------------------------
# Set the planet data
# -------------------------
func set_planet(p_data):
	planet_data = p_data
	if label:
		label.text = p_data.name
	if sprite:
		sprite.texture = p_data.sprite
		_resize_sprite_and_collision()

# -------------------------
# Ready: make clickable
# -------------------------
func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)

# -------------------------
# Handle clicks
# -------------------------
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if planet_data != null:
			planet_clicked.emit(planet_data)

# -------------------------
# Scale sprite and collision shape
# -------------------------
func _resize_sprite_and_collision():
	if sprite == null or sprite.texture == null:
		return
	
	var tex_size = sprite.texture.get_size()
	var scale_factor = TARGET_SIZE / tex_size
	var uniform_scale = min(scale_factor.x, scale_factor.y)
	sprite.scale = Vector2.ONE * uniform_scale
	
	if collision != null and collision.shape is RectangleShape2D:
		collision.shape.size = TARGET_SIZE

# Main scene structure:
# Desktop (Node2D)
# ├── Camera2D
# ├── Background (ColorRect or TextureRect)
# ├── PaperContainer (Node2D)
# │   ├── Paper1 (RigidBody2D)
# │   ├── Paper2 (RigidBody2D)
# │   └── Paper3 (RigidBody2D)
# └── DragHandler (Node2D)

# Paper.gd - Script for individual paper documents
class_name Paper
extends RigidBody2D

@export var paper_texture: Texture2D
@export var paper_color: Color = Color.WHITE

var is_being_dragged = false
var drag_offset = Vector2.ZERO
var original_gravity_scale: float
var input_area: Area2D

func _ready():
	print("Paper created at position: ", position)
	
	original_gravity_scale = gravity_scale
	gravity_scale = 0
	
	var sprite = Sprite2D.new()
	sprite.texture = paper_texture
	sprite.modulate = paper_color
	add_child(sprite)
	
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	
	if paper_texture:
		rect_shape.size = paper_texture.get_size()
		print("Using texture size: ", rect_shape.size)
	else:
		rect_shape.size = Vector2(100, 140)
		print("Using default size: ", rect_shape.size)
	
	collision_shape.shape = rect_shape
	add_child(collision_shape)
	
	# Create Area2D for input detection
	input_area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = RectangleShape2D.new()
	area_shape.size = rect_shape.size
	area_collision.shape = area_shape
	input_area.add_child(area_collision)
	add_child(input_area)
	
	input_area.input_event.connect(_on_area_input_event)
	
	linear_damp = 1.0
	angular_damp = 0.1
	
	print("Paper setup complete with Area2D input detection")

func _on_area_input_event(viewport, event, shape_idx):
	print("Area input event called! Event: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print("Mouse button left detected!")
		if event.pressed:
			start_drag(event.global_position)
		else:
			stop_drag()

func start_drag(mouse_pos: Vector2):
	print("Starting drag at: ", mouse_pos)
	is_being_dragged = true
	drag_offset = global_position - mouse_pos

func stop_drag():
	print("Stopping drag")
	is_being_dragged = false

func _process(_delta):
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
		
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 8.0, 1200.0)
			linear_velocity = velocity
		else:
			linear_velocity = Vector2.ZERO

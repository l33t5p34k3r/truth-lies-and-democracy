@icon("res://Assets/icons/drawing_pencil.svg")
class_name DrawComponent
extends Node2D

@export var topmost_provider:Node = null
@export var draw_area:Area2D

var draw_collision_shape_2d:CollisionShape2D = null
@onready var texture_rect:TextureRect = $SignTextureRect

var drawing_texture: ImageTexture
var drawing_image: Image
var is_drawing := false
var last_draw_position: Vector2
var pencil_color := Color.BLACK
var pencil_size := 2.0


var drawing_enabled:bool = false
var is_signed:bool = false
var points_drawn:float = 0.0
var points_drawn_threshold:float = 30.0



func _ready():

	if not texture_rect:
		push_error("Texture rect not set!")
	if not draw_area:
		push_error("draw_area not set!")

	draw_collision_shape_2d = draw_area.get_child(0)
	draw_area.input_event.connect(_on_area_2d_input_event)
	
	setup_drawing_surface()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	handle_input_event(event)

func handle_input_event(event:InputEvent):
	if drawing_enabled and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and topmost_provider.is_topmost_body_at_position(event.global_position):
				var pos = to_local(event.global_position) - texture_rect.position
				start_drawing(pos)
			else:
				stop_drawing()
	elif event is InputEventMouseMotion:
		if is_drawing:
			if not Input.is_action_pressed("drawing"):
				is_drawing = false
			else:
				var pos = to_local(event.global_position) - texture_rect.position
				draw_to_position(pos)

func setup_drawing_surface():
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var draw_paper_size = draw_collision_shape_2d.shape.get_rect().size
	drawing_image = Image.create(draw_paper_size.x, draw_paper_size.y, false, Image.FORMAT_RGBA8)
	
	drawing_texture = ImageTexture.new()
	drawing_texture.set_image(drawing_image)
	texture_rect.texture = drawing_texture

func start_drawing(target_position: Vector2):
	is_drawing = true
	last_draw_position = target_position
	draw_point(target_position)

func stop_drawing():
	is_drawing = false

func draw_to_position(target_position: Vector2):
	draw_line_between_points(last_draw_position, target_position)
	points_drawn += (target_position - last_draw_position).length()
	if points_drawn > points_drawn_threshold:
		is_signed = true
	last_draw_position = target_position

func draw_point(target_position: Vector2):
	var image_pos = Vector2i(int(target_position.x), int(target_position.y))
	draw_circle_on_image(image_pos, pencil_size, pencil_color)
	update_texture()

func draw_line_between_points(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = max(1, int(distance / 2))
	
	for i in range(steps + 1):
		var t = float(i) / float(steps) if steps > 0 else 0.0
		var pos = from.lerp(to, t)
		var image_pos = Vector2i(int(pos.x), int(pos.y))
		draw_circle_on_image(image_pos, pencil_size, pencil_color)
	
	update_texture()

func draw_circle_on_image(center: Vector2i, radius: float, color: Color):
	var image_size = drawing_image.get_size()
	var radius_int = int(radius)
	
	for y in range(-radius_int, radius_int + 1):
		for x in range(-radius_int, radius_int + 1):
			if x * x + y * y <= radius * radius:
				var pixel_pos = center + Vector2i(x, y)
				if pixel_pos.x >= 0 and pixel_pos.x < image_size.x and pixel_pos.y >= 0 and pixel_pos.y < image_size.y:
					drawing_image.set_pixelv(pixel_pos, color)

func update_texture():
	drawing_texture.update(drawing_image)

func set_pencil_color(color: Color):
	pencil_color = color

func set_pencil_size(size: float):
	pencil_size = clamp(size, 1.0, 20.0)

func clear_drawing():
	drawing_image.fill(Color.WHITE)
	update_texture()

func reset_sign_stats():
	points_drawn = 0.0
	is_signed = false


func on_draw_allow_change(new_drawing_enabled:bool) -> void:
	if new_drawing_enabled:
		enable_drawing()
	else:
		disable_drawing()

func enable_drawing():
	drawing_enabled = true
	stop_drawing()

func disable_drawing():
	drawing_enabled = false
	stop_drawing()

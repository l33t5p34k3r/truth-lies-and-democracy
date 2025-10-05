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
extends DragBody2D

@export var paper_texture: Texture2D
@export var paper_color: Color = Color.WHITE

signal got_stamped

var paper_headline : String = ""
var paper_content : String = ""

@onready var sprite_2d: Sprite2D = $Content/Sprite2D
@onready var text_label: Label = $Content/Control/Label
@onready var text_rich_text_label: RichTextLabel = $Content/Control/RichTextLabel
@onready var texture_rect: TextureRect = $Content/TextureRect
@onready var draw_collision_shape_2d: CollisionShape2D = $Content/Area2D/CollisionShape2D
@onready var stamp_mask: Polygon2D = $Content/StampMask
@onready var content: Node2D = $Content

@onready var infobox := preload("res://Scenes/infobox_composition.tscn").instantiate()


	

# to make papers slightly drag each other
var overlapping_papers: Array[Paper] = []

var paper_size: Vector2


var drawing_texture: ImageTexture
var drawing_image: Image
var is_drawing := false
var last_draw_position: Vector2
var pencil_color := Color.BLACK
var pencil_size := 3.0


# checks if paper has been stampged
var is_stamped = false


func _physics_process(delta):
	super._physics_process(delta)
	# Apply drag effect to overlapping papers
	if is_being_dragged and overlapping_papers.size() > 0:
		for other_paper in overlapping_papers:
			if is_instance_valid(other_paper) and other_paper != self:
				other_paper.apply_paper_drag(linear_velocity, global_position)

func start_drag(mouse_pos: Vector2):
	super.start_drag(mouse_pos)
	
	
	#z_index = 100  # High z-index to appear on top

func stop_drag():
	super.stop_drag()

	



# something breaks the paper location in this cycle
func _ready():
	super._ready()
	
	paper_size = sprite_2d.texture.get_size() * sprite_2d.scale.x
	add_news_content()
	setup_drawing_surface()
	
	add_child(infobox)
	infobox.hide()

func add_news_content():

	
	# Headline
	var headline = text_label
	headline.text = paper_headline

	headline.add_theme_font_size_override("font_size", 24)
	headline.add_theme_color_override("font_color", Color.BLACK)
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_stylebox_override("normal", create_headline_style())
	
	# Content
	var story_content = text_rich_text_label
	story_content.text = paper_content

	story_content.add_theme_font_size_override("normal_font_size", 18)
	story_content.add_theme_color_override("default_color", Color(0.2, 0.2, 0.2))
	story_content.fit_content = true
	story_content.bbcode_enabled = false
	story_content.scroll_active = false


func create_headline_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.3, 0.3, 0.6)
	return style
	

func _on_area_input_event(viewport, event, shape_idx):
	super._on_area_input_event(viewport, event, shape_idx)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and is_topmost_body_at_position(event.global_position):
				var pos = to_local(event.global_position) - texture_rect.position
				start_drawing(pos)
			else:
				stop_drawing()
	elif event is InputEventMouseMotion:
		if is_drawing:
			if not Input.is_action_pressed("stamp_down"):
				is_drawing = false
			else:
				var pos = to_local(event.global_position) - texture_rect.position
				draw_to_position(pos)
			

# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = draw_collision_shape_2d.shape.get_rect()
	return rect.has_point(pos - global_position)

func _process(delta):
	# TODO: move this to DragBody2D as well
	content.scale = content.scale.lerp(target_scale, delta * 3)
	
	if is_being_dragged:
		rotate_to_zero()

func _on_area_overlap(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and other_paper != self:
		if not overlapping_papers.has(other_paper):
			overlapping_papers.append(other_paper)

func _on_area_exit(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and overlapping_papers.has(other_paper):
		overlapping_papers.erase(other_paper)

func apply_paper_drag(drag_velocity: Vector2, drag_source_pos: Vector2):
	if is_being_dragged:  # Don't affect papers being actively dragged
		return
	
	var drag_strength = 0.45  # How much the other paper gets dragged
	var distance = global_position.distance_to(drag_source_pos)
	var max_distance = 350.0
	
	# Reduce effect based on distance
	var distance_factor = max(0.0, 1.0 - (distance / max_distance))
	var final_strength = drag_strength * distance_factor
	
	# Apply gentle impulse in direction of drag
	var drag_impulse = drag_velocity * final_strength * 0.05
	apply_central_impulse(drag_impulse)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	_on_area_input_event(viewport, event, shape_idx)

func rotate_to_zero():
	var target_rotation = 0.0
	var rotation_strength = 50.0
	
	var angle_diff = target_rotation - rotation
	
	# Normalize angle difference to [-PI, PI]
	while angle_diff > PI:
		angle_diff -= 2 * PI
	while angle_diff < -PI:
		angle_diff += 2 * PI
	
	#print("inertia is ", inertia)
	#print("Angle diff: ", angle_diff, " Current rotation: ", rotation, " Angular velocity: ", angular_velocity)
	
	# Apply torque to rotate toward zero
	if abs(angle_diff) > 0.05:  # Small threshold to prevent jitter
		var torque = angle_diff * rotation_strength
		#print("Applying torque: ", torque)
		apply_torque(torque)
		#TODO: consider current rotation speed when calculating torque
	else:
		# Apply damping when close to target to prevent oscillation
		var damping_torque = -angular_velocity * 10.0
		#print("Applying damping torque: ", damping_torque)
		apply_torque(damping_torque)

func _on_overlap_area_area_entered(area: Area2D) -> void:
	_on_area_overlap(area)


func _on_overlap_area_area_exited(area: Area2D) -> void:
	_on_area_exit(area)
	
func setup_drawing_surface():
	#texture_rect = TextureRect.new()
	#add_child(texture_rect)
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	#var paper_size = Vector2i(800, 600)
	var draw_paper_size = draw_collision_shape_2d.shape.get_rect().size
	drawing_image = Image.create(draw_paper_size.x, draw_paper_size.y, false, Image.FORMAT_RGBA8)
	#drawing_image.fill(Color.WHITE)
	
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


# does all the stamping
func add_stamp_sprite(texture: Texture2D, stamp_position: Vector2):
	var stamp = Sprite2D.new()
	stamp.texture = texture
	stamp.position = stamp_position
	stamp.rotation = -rotation
	# account for size scaling on hover
	stamp.scale = Vector2(1.0 / content.scale.x, 1.0 / content.scale.y)

	# TODO: currently, everything is fake news
	if not is_stamped:
		Manager.fake_news_published += 1

	stamp_mask.add_child(stamp)
	is_stamped = true
	got_stamped.emit()

# TODO: we need to rework mouse entry/exit events a bit, to account for overlapping papers
# i.e. paper is not topmost when mouse enters, but becomes topmost when mouse exits another paper
# also: paper is topmost, but is no longer topmost when mouse enters another overlapping paper
func _on_HoverArea_mouse_entered():
	if not is_being_dragged and is_topmost_body_at_position(get_global_mouse_position()):
		target_scale = hover_scale
		
		var metadata = {
			"headline": paper_headline,
			"content": paper_content
		}
		

		infobox.show_info(global_position, metadata)
		
# TODO: this will not be called if another paper is now highlighted -> build into DragBody2D to make sure only one paper is highlighted at a time
func _on_HoverArea_mouse_exited():
	if not is_being_dragged:
		target_scale = normal_scale
		infobox.hide_info()

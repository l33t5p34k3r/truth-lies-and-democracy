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

@export var topmost_provider:Node = null

signal got_stamped

var paper_headline : String = ""
var paper_content : String = ""
var paper_is_fake : bool = false

@onready var sprite_2d: Sprite2D = $Content/Sprite2D
@onready var text_label: Label = $Content/Control/Label
@onready var text_rich_text_label: RichTextLabel = $Content/Control/RichTextLabel
@onready var texture_rect: TextureRect = $Content/SignTextureRect
@onready var draw_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var stamp_mask: Polygon2D = $Content/StampMask
@onready var content: Node2D = $Content

var drawing_enabled:bool = false
var is_signed:bool = false
var points_drawn:float = 0.0
var points_drawn_threshold:float = 20.0

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

# something breaks the paper location in this cycle
func _ready():
	
	$Content/SignBox.visible = false
	$Content/SignLabel.visible = false
	
	paper_size = sprite_2d.texture.get_size() * sprite_2d.scale.x
	add_news_content()
	setup_drawing_surface()

func add_news_content():

	
	# Headline
	var headline = text_label
	headline.text = paper_headline

	# Content
	var story_content = text_rich_text_label
	story_content.text = paper_content


func create_headline_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.3, 0.3, 0.6)
	return style
	

func _on_area_input_event(_viewport, event, _shape_idx):

	if drawing_enabled and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and topmost_provider.is_topmost_body_at_position(event.global_position):
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

#func _process(delta):
	# TODO: move this to highlighting_component
	#content.scale = content.scale.lerp(target_scale, delta * 3)
	

func _on_area_overlap(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and other_paper != self:
		if not overlapping_papers.has(other_paper):
			overlapping_papers.append(other_paper)

func _on_area_exit(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and overlapping_papers.has(other_paper):
		overlapping_papers.erase(other_paper)

#TODO: add to drag_component and think if its useful there
#func apply_paper_drag(drag_velocity: Vector2, drag_source_pos: Vector2):
	##if is_being_dragged:  # Don't affect papers being actively dragged
		##return
	#
	#var drag_strength = 0.45  # How much the other paper gets dragged
	#var distance = global_position.distance_to(drag_source_pos)
	#var max_distance = 350.0
	#
	## Reduce effect based on distance
	#var distance_factor = max(0.0, 1.0 - (distance / max_distance))
	#var final_strength = drag_strength * distance_factor
	#
	## Apply gentle impulse in direction of drag
	#var drag_impulse = drag_velocity * final_strength * 0.05
	#apply_central_impulse(drag_impulse)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	_on_area_input_event(viewport, event, shape_idx)



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

func enable_drawing():
	$Content/SignBox.visible = true
	$Content/SignLabel.visible = true
	drawing_enabled = true
	stop_drawing()

# does all the stamping
func add_stamp_sprite(texture: Texture2D, stamp_position: Vector2):
	var stamp = Sprite2D.new()
	stamp.texture = texture
	stamp.position = stamp_position
	stamp.rotation = -rotation
	# account for size scaling on hover
	stamp.scale = Vector2(1.0 / content.scale.x, 1.0 / content.scale.y)

	if not is_stamped and self.paper_is_fake:
		Manager.fake_news_published += 1

	stamp_mask.add_child(stamp)
	is_stamped = true
	got_stamped.emit()

# TODO: we need to rework mouse entry/exit events a bit, to account for overlapping papers
# i.e. paper is not topmost when mouse enters, but becomes topmost when mouse exits another paper
# also: paper is topmost, but is no longer topmost when mouse enters another overlapping paper

# TODO: add function into drag_component and make infobox actually a component


		
## TODO: this will not be called if another paper is now highlighted -> build into DragBody2D to make sure only one paper is highlighted at a time

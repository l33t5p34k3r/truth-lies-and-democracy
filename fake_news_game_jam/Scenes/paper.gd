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
static var currently_dragging_paper: Paper = null
static var all_papers: Array[Paper] = []
static var paper_stack_order: Array[Paper] = []  # Bottom to top order

var drag_offset = Vector2.ZERO
var glob_pos = Vector2.ZERO
var mouse_pos_ = Vector2.ZERO
var original_gravity_scale: float
var input_area: Area2D
var paper_size: Vector2
var original_z_index: int = 0

var drawing_texture: ImageTexture
var drawing_image: Image
var is_drawing := false
var last_draw_position: Vector2
var pencil_color := Color.BLACK
var pencil_size := 3.0
@onready var texture_rect: TextureRect
# keeps checked if paper has been stamped
var is_stamped = false

var boundary_rect: Rect2 = Rect2(-50, -50, 1380, 790)  # x, y, width, height
var boundary_margin: float = 10.0  # Extra space for half paper size

var news_headlines = [
	"Local Cat Wins Mayor Election",
	"Scientists Discover Coffee Beans Can Fly", 
	"Traffic Light Goes on Strike",
	"Pizza Delivery Via Drone Causes Chaos",
	"Weather Report: It's Definitely Outside",
	"Breaking: Pencils Found to Contain Lead",
	"Local Man Loses Keys in Own Pocket",
	"Study Shows 100% of Studies Are Studies"
]

var news_content = [
	"In a shocking turn of events, Mr. Whiskers defeated incumbent mayor by promising more nap time and mandatory laser pointer sessions for all citizens.",
	"Researchers at the Institute of Caffeinated Sciences announced that coffee beans exhibit flight patterns when nobody is watching, explaining missing morning coffee.",
	"The intersection's traffic light issued a formal complaint about working conditions, demanding better weather protection and longer lunch breaks.",
	"Emergency services responded to seventeen reports of pizzas landing in unexpected locations after drone navigation systems confused 'delivery' with 'bombing run.'",
	"Local meteorologist confirms that weather continues to occur outdoors, urging citizens to 'check by looking through windows or stepping outside.'",
	"Archaeological expedition into desk drawers reveals ancient pencils containing mysterious graphite substance previously thought to be actual lead.",
	"Area resident spent three hours searching for missing keys before discovering them in the very pocket he'd checked 47 times previously.",
	"Groundbreaking meta-analysis confirms that research studies are indeed studies, revolutionizing the field of study identification and classification."
]

func _exit_tree() -> void:
	all_papers.erase(self)
	paper_stack_order.erase(self)
	update_all_z_indices()

func register_paper():
	all_papers.append(self)
	paper_stack_order.append(self)
	update_all_z_indices()

func _ready():
	register_paper()
	print("Paper created at position: ", position)
	paper_size = $Sprite2D.texture.get_size() * $Sprite2D.scale.x
	add_news_content()
	
	original_z_index = z_index
	
	setup_drawing_surface()
	
	
	print("Paper setup complete with Area2D input detection")


func add_news_content():
	var content_container = $Control
	#content_container.size = paper_size
	#content_container.position = Vector2(-paper_size.x * 0.5, -paper_size.y * 0.5)
	#add_child(content_container)
	
	var article_index = randi() % news_headlines.size()
	
	# Headline
	var headline = $Control/Label
	headline.text = news_headlines[article_index]
	#headline.position = Vector2(8, 8)
	#headline.size = Vector2(paper_size.x - 16, 25)
	headline.add_theme_font_size_override("font_size", 24)
	headline.add_theme_color_override("font_color", Color.BLACK)
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_stylebox_override("normal", create_headline_style())
	#content_container.add_child(headline)
	
	# Content
	var content = $Control/RichTextLabel
	content.text = news_content[article_index]
	#content.position = Vector2(8, 38)
	#content.size = Vector2(paper_size.x - 16, paper_size.y - 46)
	content.add_theme_font_size_override("normal_font_size", 18)
	content.add_theme_color_override("default_color", Color(0.2, 0.2, 0.2))
	content.fit_content = true
	content.bbcode_enabled = false
	content.scroll_active = false
	#content_container.add_child(content)

func create_headline_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.3, 0.3, 0.6)
	return style
	
	
func _on_area_input_event(viewport, event, shape_idx):
	#print("Area input event called! Event: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Mouse button left detected!")
		glob_pos = global_position
		mouse_pos_ = event.global_position
		if event.pressed and currently_dragging_paper == null and is_topmost_paper_at_position(event.global_position):
			start_drag(event.global_position)
		#else:
			#stop_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and is_topmost_paper_at_position(event.global_position):
				var pos = to_local(event.global_position) - $TextureRect.position
				start_drawing(pos)
			else:
				stop_drawing()
	elif event is InputEventMouseMotion:
		if is_drawing:
			if not Input.is_action_pressed("stamp_down"):
				is_drawing = false
			else:
				var pos = to_local(event.global_position) - $TextureRect.position
				draw_to_position(pos)
			
func is_topmost_paper_at_position(pos: Vector2) -> bool:
	# Check all papers at this position and see if this one is on top
	var papers_at_pos: Array[Paper] = []
	
	for paper in all_papers:
		if paper.is_position_inside_paper(pos):
			papers_at_pos.append(paper)
	
	if papers_at_pos.is_empty():
		return false
	
	# Find the paper with highest z-index (last in stack order)
	var topmost_paper = papers_at_pos[0]
	for paper in papers_at_pos:
		if paper_stack_order.find(paper) > paper_stack_order.find(topmost_paper):
			topmost_paper = paper
	
	return topmost_paper == self
			
func is_position_inside_paper(pos: Vector2) -> bool:
	var half_size = paper_size * 0.5
	var paper_rect = Rect2(global_position - half_size, paper_size)
	return paper_rect.has_point(pos)
			
func _unhandled_input(event):
	if is_being_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#print("Global mouse release detected - stopping drag")
			stop_drag()
			
func start_drag(mouse_pos: Vector2):
	#print("Starting drag at: ", mouse_pos)
	is_being_dragged = true
	drag_offset = global_position - mouse_pos
	currently_dragging_paper = self
	
	z_index = 100  # High z-index to appear on top

func stop_drag():
	#print("Stopping drag")
	is_being_dragged = false
	currently_dragging_paper = null
	#z_index = original_z_index
	
	
	bring_to_top()

func bring_to_top():
	# Remove from current position and add to end (top)
	paper_stack_order.erase(self)
	paper_stack_order.append(self)
	update_all_z_indices()

static func update_all_z_indices():
	# Assign z-indices based on position in stack (0 = bottom, higher = top)
	for i in range(paper_stack_order.size()):
		var paper = paper_stack_order[i]
		if paper != currently_dragging_paper:  # Don't change z-index while dragging
			paper.z_index = i

func _process(_delta):
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
		
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 25.0, 4500.0)
			linear_velocity = velocity
		else:
			linear_velocity = Vector2.ZERO
		rotate_to_zero(_delta)
			
			
	apply_boundary_constraints()
			
	DebugDraw.draw_velocity(self, -drag_offset, 0.2)
	DebugDraw.draw_boundary(boundary_rect, Color.ORANGE)
	if is_being_dragged:
		DebugDraw.draw_point(drag_offset, Color.RED)
		DebugDraw.draw_point(mouse_pos_, Color.GREEN)
		DebugDraw.draw_point(glob_pos, Color.CHARTREUSE)

var overlapping_papers: Array[Paper] = []

func _physics_process(delta):
	# Apply drag effect to overlapping papers
	if is_being_dragged and overlapping_papers.size() > 0:
		for other_paper in overlapping_papers:
			if is_instance_valid(other_paper) and other_paper != self:
				other_paper.apply_paper_drag(linear_velocity, global_position)

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

func rotate_to_zero(delta: float):
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
		


func apply_boundary_constraints():
	# TODO: this is a pretty bad constraint
	var half_size = paper_size * 0.5
	var min_pos = boundary_rect.position + half_size
	var max_pos = boundary_rect.position + boundary_rect.size - half_size
	
	var new_position = global_position
	var apply_force = false
	var bounce_force = Vector2.ZERO
	
	# Check X boundaries
	if global_position.x < min_pos.x:
		new_position.x = min_pos.x
		if linear_velocity.x < 0:
			bounce_force.x = -linear_velocity.x * 0.5
		apply_force = true
	elif global_position.x > max_pos.x:
		new_position.x = max_pos.x
		if linear_velocity.x > 0:
			bounce_force.x = -linear_velocity.x * 0.5
		apply_force = true
	
	# Check Y boundaries  
	if global_position.y < min_pos.y:
		new_position.y = min_pos.y
		if linear_velocity.y < 0:
			bounce_force.y = -linear_velocity.y * 0.5
		apply_force = true
	elif global_position.y > max_pos.y:
		new_position.y = max_pos.y
		if linear_velocity.y > 0:
			bounce_force.y = -linear_velocity.y * 0.5
		apply_force = true
	
	# Apply corrections
	if apply_force:
		global_position = new_position
		if not is_being_dragged:  # Only bounce when not being dragged
			linear_velocity += bounce_force

func _on_overlap_area_area_entered(area: Area2D) -> void:
	_on_area_overlap(area)


func _on_overlap_area_area_exited(area: Area2D) -> void:
	_on_area_exit(area)

	
func setup_drawing_surface():
	#texture_rect = TextureRect.new()
	texture_rect = $TextureRect
	#add_child(texture_rect)
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	#var paper_size = Vector2i(800, 600)
	var paper_size = $Area2D/CollisionShape2D.shape.get_rect().size
	drawing_image = Image.create(paper_size.x, paper_size.y, false, Image.FORMAT_RGBA8)
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
func add_stamp_sprite(texture: Texture2D, position: Vector2):
	var stamp = Sprite2D.new()
	stamp.texture = texture
	stamp.position = position
	stamp.rotation = -rotation
	#stamp.rotation_degrees = randf_range(-10, 10)  # Optional: add some variation
	#stamp.scale = Vector2.ONE * randf_range(0.9, 1.1)  # Optional: slight scale variation
	$StampMask.add_child(stamp)
	is_stamped=true

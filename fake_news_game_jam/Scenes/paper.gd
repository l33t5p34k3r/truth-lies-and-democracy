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
var glob_pos = Vector2.ZERO
var mouse_pos_ = Vector2.ZERO
var original_gravity_scale: float
var input_area: Area2D
var paper_size: Vector2

var boundary_rect: Rect2 = Rect2(50, 50, 1180, 620)  # x, y, width, height
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


func _ready():
	print("Paper created at position: ", position)
	paper_size = $Sprite2D.texture.get_size() * $Sprite2D.scale.x
	add_news_content()
	
	
	
	
	#original_gravity_scale = gravity_scale
	#gravity_scale = 0
	
	#var sprite = Sprite2D.new()
	#sprite.texture = paper_texture
	#sprite.modulate = paper_color
	#add_child(sprite)
	
	#var collision_shape = CollisionShape2D.new()
	#var rect_shape = RectangleShape2D.new()
	#
	#if paper_texture:
		#rect_shape.size = paper_texture.get_size()
		#print("Using texture size: ", rect_shape.size)
	#else:
		#rect_shape.size = Vector2(100, 140)
		#print("Using default size: ", rect_shape.size)
	
	#collision_shape.shape = rect_shape
	#add_child(collision_shape)
	
	# Create Area2D for input detection
	#input_area = Area2D.new()
	#var area_collision = CollisionShape2D.new()
	#var area_shape = RectangleShape2D.new()
	#area_shape.size = rect_shape.size
	#area_collision.shape = area_shape
	#input_area.add_child(area_collision)
	#add_child(input_area)
	
	#input_area.input_event.connect(_on_area_input_event)
	
	#linear_damp = 1.0
	#angular_damp = 0.1
	
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
	headline.add_theme_font_size_override("font_size", 11)
	headline.add_theme_color_override("font_color", Color.BLACK)
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_stylebox_override("normal", create_headline_style())
	#content_container.add_child(headline)
	
	# Content
	var content = $Control/RichTextLabel
	content.text = news_content[article_index]
	#content.position = Vector2(8, 38)
	#content.size = Vector2(paper_size.x - 16, paper_size.y - 46)
	content.add_theme_font_size_override("normal_font_size", 8)
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
		if event.pressed:
			start_drag(event.global_position)
		#else:
			#stop_drag()
			
func _unhandled_input(event):
	if is_being_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			print("Global mouse release detected - stopping drag")
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
			var velocity = direction.normalized() * min(distance * 16.0, 2400.0)
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

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	_on_area_input_event(viewport, event, shape_idx)

func rotate_to_zero(delta: float):
	var target_rotation = 0.0
	var rotation_strength = 40.0
	
	var angle_diff = target_rotation - rotation
	
	# Normalize angle difference to [-PI, PI]
	while angle_diff > PI:
		angle_diff -= 2 * PI
	while angle_diff < -PI:
		angle_diff += 2 * PI
	
	print("inertia is ", inertia)
	print("Angle diff: ", angle_diff, " Current rotation: ", rotation, " Angular velocity: ", angular_velocity)
	
	# Apply torque to rotate toward zero
	if abs(angle_diff) > 0.05:  # Small threshold to prevent jitter
		var torque = angle_diff * rotation_strength
		print("Applying torque: ", torque)
		apply_torque(torque)
	else:
		# Apply damping when close to target to prevent oscillation
		#var damping_torque = -angular_velocity * 10.0
		#print("Applying damping torque: ", damping_torque)
		#apply_torque(damping_torque)
		var torque = angle_diff * (rotation_strength / 5)
		print("Applying torque: ", torque)
		apply_torque(torque)
		


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

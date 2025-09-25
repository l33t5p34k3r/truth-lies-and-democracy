# DebugDraw.gd - Global debug drawing system
extends Node

const DEBUG_ENABLED = false
const VELOCITY_COLOR = Color.CYAN
const FORCE_COLOR = Color.RED
const IMPULSE_COLOR = Color.YELLOW
const ACCELERATION_COLOR = Color.GREEN
const POINT_COLOR = Color.MAGENTA

var debug_lines: Array[Line2D] = []
var debug_points: Array[Node2D] = []

func _ready():
	if not DEBUG_ENABLED:
		return
	set_process(true)

func _process(_delta):
	if not DEBUG_ENABLED:
		return
	clear_debug_lines()
	clear_debug_points()

func clear_debug_lines():
	for line in debug_lines:
		if is_instance_valid(line):
			line.queue_free()
	debug_lines.clear()

func clear_debug_points():
	for point in debug_points:
		if is_instance_valid(point):
			point.queue_free()
	debug_points.clear()

func draw_vector(start_pos: Vector2, vector: Vector2, color: Color = Color.WHITE, scale: float = 1.0, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	
	if parent == null:
		parent = get_tree().current_scene
	
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = color
	line.z_index = 100
	
	var end_pos = start_pos + (vector * scale)
	line.add_point(start_pos)
	line.add_point(end_pos)
	
	# Add arrowhead
	if vector.length() > 0:
		var arrow_size = 8.0
		var direction = vector.normalized()
		var perpendicular = Vector2(-direction.y, direction.x)
		
		var arrow_point1 = end_pos - (direction * arrow_size) + (perpendicular * arrow_size * 0.5)
		var arrow_point2 = end_pos - (direction * arrow_size) - (perpendicular * arrow_size * 0.5)
		
		line.add_point(arrow_point1)
		line.add_point(end_pos)
		line.add_point(arrow_point2)
	
	parent.add_child(line)
	debug_lines.append(line)

func draw_velocity(body: RigidBody2D, offset: Vector2 = Vector2.ZERO, scale: float = 0.1):
	if not DEBUG_ENABLED:
		return
	draw_vector(body.global_position + offset, body.linear_velocity, VELOCITY_COLOR, scale, body.get_parent())

func draw_force(start_pos: Vector2, force: Vector2, scale: float = 0.01, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	draw_vector(start_pos, force, FORCE_COLOR, scale, parent)

func draw_impulse(start_pos: Vector2, impulse: Vector2, scale: float = 1.0, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	draw_vector(start_pos, impulse, IMPULSE_COLOR, scale, parent)

func draw_acceleration(start_pos: Vector2, acceleration: Vector2, scale: float = 1.0, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	draw_vector(start_pos, acceleration, ACCELERATION_COLOR, scale, parent)

func draw_point(pos: Vector2, color: Color = POINT_COLOR, size: float = 8.0, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	
	if parent == null:
		parent = get_tree().current_scene
	
	var point_marker = Node2D.new()
	point_marker.position = pos
	point_marker.z_index = 101
	
	# Create cross-hair marker
	var line1 = Line2D.new()
	line1.width = 2.0
	line1.default_color = color
	line1.add_point(Vector2(-size, 0))
	line1.add_point(Vector2(size, 0))
	
	var line2 = Line2D.new()
	line2.width = 2.0
	line2.default_color = color
	line2.add_point(Vector2(0, -size))
	line2.add_point(Vector2(0, size))
	
	# Create circle outline
	var circle = Line2D.new()
	circle.width = 1.5
	circle.default_color = color
	var segments = 16
	for i in range(segments + 1):
		var angle = (i * 2 * PI) / segments
		var point = Vector2(cos(angle), sin(angle)) * size * 0.7
		circle.add_point(point)
	
	point_marker.add_child(line1)
	point_marker.add_child(line2)
	point_marker.add_child(circle)
	
	parent.add_child(point_marker)
	debug_points.append(point_marker)
	
func draw_boundary(rect: Rect2, color: Color = Color.WHITE, parent: Node2D = null):
	if not DEBUG_ENABLED:
		return
	
	if parent == null:
		parent = get_tree().current_scene
	
	var boundary_line = Line2D.new()
	boundary_line.width = 2.0
	boundary_line.default_color = color
	boundary_line.z_index = 50
	
	# Draw rectangle outline
	boundary_line.add_point(rect.position)
	boundary_line.add_point(Vector2(rect.position.x + rect.size.x, rect.position.y))
	boundary_line.add_point(rect.position + rect.size)
	boundary_line.add_point(Vector2(rect.position.x, rect.position.y + rect.size.y))
	boundary_line.add_point(rect.position)  # Close the rectangle
	
	parent.add_child(boundary_line)
	debug_lines.append(boundary_line)

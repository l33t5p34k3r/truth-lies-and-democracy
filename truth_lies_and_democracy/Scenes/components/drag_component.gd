extends Node2D

@export var target_node : RigidBody2D = null
@export var click_target_node : Area2D =  null

var glob_pos = Vector2.ZERO
var is_being_dragged = false
var drag_offset = Vector2.ZERO
var boundary_rect = Rect2(Vector2.ZERO, Vector2.ZERO)

var normal_scale = Vector2(1.0, 1.0)
var hover_scale = Vector2(1.2, 1.2)
var original_z_index: int = 0

var target_scale = normal_scale

static var currently_dragging_body: RigidBody2D = null
static var all_dragbodies: Array[RigidBody2D] = []
static var body_stack_order: Array[RigidBody2D] = []  # Bottom to top order


# default
var damp_percentage = 0.90


func _ready():
	if not click_target_node or not target_node:
		push_error("target nodes not set")
		
	click_target_node.input_event.connect(_on_area_input_event)
	boundary_rect = get_viewport().get_visible_rect()
	register_dragbody()
	original_z_index = z_index
	
func _process(_delta):
	if is_being_dragged:
		rotate_to_zero()


func _physics_process(_delta: float) -> void:
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
	
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 16.0, 2400.0)
			target_node.linear_velocity = velocity
		else:
			target_node.linear_velocity = Vector2.ZERO
			
	else:
		target_node.linear_velocity *= damp_percentage

	# check if item is still being dragged
	if is_being_dragged and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		stop_drag()

	# check that item does not flee the screen
	apply_boundary_constraints()


func start_drag(mouse_pos: Vector2):
	is_being_dragged = true
	currently_dragging_body = target_node
	drag_offset = global_position - mouse_pos
	
	target_node.z_index = 100  # High z-index to appear on top

func rotate_to_zero():
	var target_rotation := 0.0
	var rotation_strength := 50.0
	var damping_strength := 10.0

	var angle_diff := target_rotation - target_node.rotation
	angle_diff = wrapf(angle_diff, -PI, PI)  # cleaner normalization

	var angular_velocity := target_node.angular_velocity

	if abs(angle_diff) > 0.05:
		# Predictive damping: reduce torque if already rotating toward target
		var torque := angle_diff * rotation_strength - angular_velocity * damping_strength
		target_node.apply_torque(torque)
	else:
		# Near target: apply damping only
		var damping_torque := -angular_velocity * damping_strength

		target_node.apply_torque(damping_torque)

func stop_drag():
	is_being_dragged = false
	currently_dragging_body = null
	bring_to_top()

func apply_boundary_constraints():
	var min_pos = boundary_rect.position
	var max_pos = boundary_rect.position + boundary_rect.size
	
	var corrected := false
	var bounce := Vector2.ZERO

	# Clamp position
	var clamped_pos = Vector2(
		clamp(global_position.x, min_pos.x, max_pos.x),
		clamp(global_position.y, min_pos.y, max_pos.y)
	)
	
	if clamped_pos != global_position:
		corrected = true
		global_position = clamped_pos
		
		# Apply bounce only if moving toward the boundary
		if target_node.linear_velocity.x < 0 and global_position.x == min_pos.x:
			bounce.x = -target_node.linear_velocity.x * 0.5
		elif target_node.linear_velocity.x > 0 and global_position.x == max_pos.x:
			bounce.x = -target_node.linear_velocity.x * 0.5

		if target_node.linear_velocity.y < 0 and global_position.y == min_pos.y:
			bounce.y = -target_node.linear_velocity.y * 0.5
		elif target_node.linear_velocity.y > 0 and global_position.y == max_pos.y:
			bounce.y = -target_node.linear_velocity.y * 0.5

	# Apply bounce impulse if needed
	if corrected and not is_being_dragged:
		target_node.linear_velocity += bounce


func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_topmost_body_at_position(event.global_position):
		glob_pos = global_position
		start_drag(event.global_position)

func _on_HoverArea_mouse_entered():
	if not is_being_dragged:
		$Area2D.scale = hover_scale
		
func _on_HoverArea_mouse_exited():
	if not is_being_dragged:
		$Area2D.scale = normal_scale


static func update_all_z_indices():
	# Assign z-indices based on position in stack (0 = bottom, higher = top)
	for i in range(body_stack_order.size()):
		var body = body_stack_order[i]
		if body != currently_dragging_body:  # Don't change z-index while dragging
			body.z_index = i

func bring_to_top():
	# Remove from current position and add to end (top)
	body_stack_order.erase(target_node)
	body_stack_order.append(target_node)
	update_all_z_indices()
	

func _exit_tree() -> void:
	all_dragbodies.erase(target_node)
	body_stack_order.erase(target_node)
	update_all_z_indices()

func register_dragbody():
	all_dragbodies.append(target_node)
	body_stack_order.append(target_node)
	update_all_z_indices()
	
func is_topmost_body_at_position(pos: Vector2) -> bool:
	var bodies_at_pos: Array[RigidBody2D] = []
	
	for body in all_dragbodies:
		if body.is_position_inside_body(pos):
			bodies_at_pos.append(body)
	
	if bodies_at_pos.is_empty():
		return false
	
	# Find the body with highest z-index (last in stack order)
	var topmost_body = bodies_at_pos[0]
	for body in bodies_at_pos:
		if body_stack_order.find(body) > body_stack_order.find(topmost_body):
			topmost_body = body
	
	return topmost_body == target_node
	

func is_position_inside_body(_pos: Vector2) -> bool:
	# implement this in the child class!
	push_error("This function should not be called directly!")
	return false

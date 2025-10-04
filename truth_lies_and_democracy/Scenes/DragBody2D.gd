class_name DragBody2D
extends RigidBody2D

var glob_pos = Vector2.ZERO
var is_being_dragged = false
var drag_offset = Vector2.ZERO
var boundary_rect = Rect2(Vector2.ZERO, Vector2.ZERO)

var normal_scale = Vector2(0.53,0.53)
var hover_scale = Vector2(0.6,0.6)

var target_scale = normal_scale


# default
var damp_percentage = 0.90


func _ready():
	boundary_rect = get_viewport().get_visible_rect()


func _physics_process(_delta: float) -> void:
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
	
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 16.0, 2400.0)
			linear_velocity = velocity
		else:
			linear_velocity = Vector2.ZERO
			
	else:
		linear_velocity *= damp_percentage

	# check if item is still being dragged
	if is_being_dragged and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		stop_drag()

	# check that item does not flee the screen
	apply_boundary_constraints()


func start_drag(mouse_pos: Vector2):
	is_being_dragged = true
	drag_offset = global_position - mouse_pos
	
	z_index = 100  # High z-index to appear on top

func stop_drag():
	is_being_dragged = false

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
		if linear_velocity.x < 0 and global_position.x == min_pos.x:
			bounce.x = -linear_velocity.x * 0.5
		elif linear_velocity.x > 0 and global_position.x == max_pos.x:
			bounce.x = -linear_velocity.x * 0.5

		if linear_velocity.y < 0 and global_position.y == min_pos.y:
			bounce.y = -linear_velocity.y * 0.5
		elif linear_velocity.y > 0 and global_position.y == max_pos.y:
			bounce.y = -linear_velocity.y * 0.5

	# Apply bounce impulse if needed
	if corrected and not is_being_dragged:
		linear_velocity += bounce


func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		glob_pos = global_position
		start_drag(event.global_position)

func _on_HoverArea_mouse_entered():
	if not is_being_dragged:
		$Area2D.scale = hover_scale
		
func _on_HoverArea_mouse_exited():
	if not is_being_dragged:
		$Area2D.scale = normal_scale

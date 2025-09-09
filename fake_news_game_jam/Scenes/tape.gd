class_name Tape
extends RigidBody2D

var glob_pos = Vector2.ZERO
var mouse_pos = Vector2.ZERO
var is_being_dragged = false

var drag_offset = Vector2.ZERO

var boundary_rect: Rect2 = Rect2(50, 50, 1240, 700)  # x, y, width, height

func playTape():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
		
func stopTape():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()

func _process(delta: float) -> void:
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
	
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 16.0, 2400.0)
			linear_velocity = velocity
		else:
			linear_velocity = Vector2.ZERO

	apply_boundary_constraints()
	
func _on_area_input_event(_viewport, event, _shape_idx):
	#print("Area input event called! Event: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Mouse button left detected!")
		glob_pos = global_position
		mouse_pos = event.global_position
		start_drag(event.global_position)
		
func start_drag(mouse_pos: Vector2):
	#print("Starting drag at: ", mouse_pos)
	is_being_dragged = true
	drag_offset = global_position - mouse_pos
	
	z_index = 100  # High z-index to appear on top
	
func stop_drag():
	#print("Stopping drag")
	is_being_dragged = false
	
func _unhandled_input(event):
	if is_being_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#print("Global mouse release detected - stopping drag")
			stop_drag()



func apply_boundary_constraints():
	# TODO: this is a pretty bad constraint
	var min_pos = boundary_rect.position
	var max_pos = boundary_rect.position + boundary_rect.size
	
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

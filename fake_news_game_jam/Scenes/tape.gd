class_name Tape
extends RigidBody2D

var glob_pos = Vector2.ZERO
var mouse_pos = Vector2.ZERO
var is_being_dragged = false

var drag_offset = Vector2.ZERO

func playTape():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

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

func _on_area_input_event(_viewport, event, _shape_idx):
	#print("Area input event called! Event: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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

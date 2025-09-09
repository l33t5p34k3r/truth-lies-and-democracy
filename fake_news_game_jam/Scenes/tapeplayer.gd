extends RigidBody2D

var glob_pos = Vector2.ZERO
var mouse_pos = Vector2.ZERO
var is_being_dragged = false
var drag_offset = Vector2.ZERO

var tapeArray: Array[Tape] = []

var playingTape: Tape = null

func _on_area_input_event(_viewport, event, _shape_idx):
	#print("Area input event called! Event: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Mouse button left detected!")
		glob_pos = global_position
		mouse_pos = event.global_position
		start_drag(event.global_position)

func _unhandled_input(event):
	if is_being_dragged and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#print("Global mouse release detected - stopping drag")
			stop_drag()

func start_drag(mouse_pos: Vector2):
	#print("Starting drag at: ", mouse_pos)
	is_being_dragged = true
	drag_offset = global_position - mouse_pos
	
	z_index = 100  # High z-index to appear on top
	
func stop_drag():
	#print("Stopping drag")
	is_being_dragged = false
	
	
func _process(_delta):
	
	
	if playingTape:
		
		playingTape.playTape()
	
	for tape in tapeArray:
		pull_object_towards_target(tape, self.global_position, 9000 * _delta, 999999999)
		if tape.global_position.distance_to(self.global_position) <= 30:
			playingTape = tape
	
	if is_being_dragged:
		var target_position = get_global_mouse_position() + drag_offset
		var direction = target_position - global_position
		var distance = direction.length()
		
		if distance > 5.0:
			var velocity = direction.normalized() * min(distance * 16.0, 2400.0)
			linear_velocity = velocity
		else:
			linear_velocity = Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Tape:
		tapeArray.append(body)
		
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	tapeArray.erase(body)


func pull_object_towards_target(physics_body: RigidBody2D, target_position: Vector2, pull_strength: float, max_distance: float = 100.0, damping_radius: float = 20.0):
	var current_position = physics_body.global_position
	var distance_to_target = current_position.distance_to(target_position)

 
	var direction = (target_position - current_position).normalized()
	var distance_factor = 1.0 - distance_to_target / max_distance
	var pull_force = direction * pull_strength * distance_factor
 
  #Apply stronger damping when close to target
	if distance_to_target < damping_radius:
		var velocity_towards_target = physics_body.linear_velocity.dot(direction)
		var damping_factor = (damping_radius - distance_to_target) / damping_radius
		var damping_force = -direction * velocity_towards_target * pull_strength * damping_factor * 2.0
		pull_force += damping_force
 
	physics_body.apply_central_force(pull_force)

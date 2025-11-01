class_name TapePlayer
extends RigidBody2D

var tapeArray: Array[Tape] = []
var playingTape: Tape = null

func _process(_delta):
	
	if playingTape:
		
		playingTape.playTape()
	
	for tape in tapeArray:
		pull_object_towards_target(tape, self.global_position, 35000 * _delta, 999999999)
		if tape.global_position.distance_to(self.global_position) <= 30:
			playingTape = tape


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Tape:
		tapeArray.append(body)
			
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == playingTape:
		playingTape.stopTape()
	tapeArray.erase(body)

func pull_object_towards_target(
	physics_body: RigidBody2D,
	target_position: Vector2,
	pull_strength: float,
	_max_distance: float = 100.0,
	damping_radius: float = 25.0,
	snap_threshold: float = 10.0
):
	var current_position = physics_body.global_position
	var to_target = target_position - current_position
	var distance = to_target.length()

	if distance < snap_threshold and physics_body.linear_velocity.length() < 1.0:
		# Snap to target if very close and nearly still
		physics_body.global_position = target_position
		physics_body.linear_velocity = Vector2.ZERO
		return

	var direction = to_target.normalized()

	var pull_force = direction * pull_strength

	# Predictive damping when close
	if distance < damping_radius:
		var velocity_towards_target = physics_body.linear_velocity.dot(direction)
		var damping_factor = (damping_radius - distance) / damping_radius
		var damping_force = -direction * velocity_towards_target * damping_factor * pull_strength * 0.5
		pull_force += damping_force

	# Optional: clamp force to avoid jitter
	var max_force = pull_strength * 1.2
	if pull_force.length() > max_force:
		pull_force = pull_force.normalized() * max_force

	physics_body.apply_central_force(pull_force)



# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = $CollisionShape2D.shape.get_rect()
	return rect.has_point(pos - global_position)

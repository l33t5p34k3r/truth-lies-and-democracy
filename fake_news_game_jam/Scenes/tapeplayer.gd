class_name TapePlayer
extends DragBody2D

var tapeArray: Array[Tape] = []
var playingTape: Tape = null

func _process(_delta):
	
	if playingTape:
		
		playingTape.playTape()
	
	for tape in tapeArray:
		pull_object_towards_target(tape, self.global_position, 9000 * _delta, 999999999)
		if tape.global_position.distance_to(self.global_position) <= 30:
			playingTape = tape


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Tape:
		tapeArray.append(body)
			
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == playingTape:
		playingTape.stopTape()
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

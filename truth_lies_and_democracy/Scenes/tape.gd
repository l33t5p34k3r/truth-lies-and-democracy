class_name Tape
extends DragBody2D


func playTape():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
		
func stopTape():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()

# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = $CollisionShape2D.shape.get_rect()
	return rect.has_point(pos - global_position)

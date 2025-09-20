class_name Tape
extends DragBody2D


func playTape():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
		
func stopTape():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()

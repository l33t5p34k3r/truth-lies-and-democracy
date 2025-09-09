class_name Tape
extends RigidBody2D

func playTape():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

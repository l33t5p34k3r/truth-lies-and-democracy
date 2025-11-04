class_name StickyNoteFinal
extends RigidBody2D

@onready var draw_collision_shape_2d: CollisionShape2D = $DrawArea/CollisionShape2D
@onready var draw_component: DrawComponent = $DrawComponent

func is_position_inside_body(pos: Vector2) -> bool:
	var rect = draw_collision_shape_2d.shape.get_rect()
	return rect.has_point(pos - global_position)

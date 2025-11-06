extends RigidBody2D

var radius:float = 10.0

@onready var drag_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@onready var minute_line: Line2D = $MinuteLine
@onready var hour_line: Line2D = $HourLine

# set to 0 for pausing
@export var time_scale: float = 60.0
@export var total_minutes: float = 0.0

func _ready():
	radius = $CollisionShape2D.shape.radius
	
func _process(delta: float) -> void:
	var minutes_passed = (delta / 60.0) * time_scale
	total_minutes += minutes_passed
	var minute_rotation_degrees = total_minutes * 6.0
	var hour_rotation_degrees = total_minutes * 0.5
	
	minute_line.rotation = deg_to_rad(minute_rotation_degrees)
	hour_line.rotation = deg_to_rad(hour_rotation_degrees)


func _draw():
	draw_circle(Vector2(0, 0), radius, Color.WHITE)
	draw_circle(Vector2(0, 0), radius + 2, Color.BLACK, false)



# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = drag_collision_shape_2d.shape.get_rect()
	return rect.has_point(pos - global_position)

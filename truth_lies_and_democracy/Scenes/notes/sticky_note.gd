class_name StickyNote
extends RigidBody2D
@onready var draw_collision_shape_2d: CollisionShape2D = $DrawArea/CollisionShape2D
@onready var draw_component: DrawComponent = $DrawComponent

@onready var detach_highlighter: Polygon2D = %DetachHighlighter


#TODO: using this one "inside" check isn't ideal, since drawing and dragging may use different areas :(
# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = draw_collision_shape_2d.shape.get_rect()
	return rect.has_point(pos - global_position)


const STICKY_NOTE_FINAL = preload("uid://c27xwxxxipikn")

var detach_tween = null
var detach_hover_done:bool = false

func _detach_reset():
	if detach_tween:
		detach_tween.kill()
	detach_hover_done = false
	detach_highlighter.color.a = 0
	

func _on_detach_area_mouse_entered() -> void:
	_detach_reset()
	detach_tween = get_tree().create_tween().bind_node(self)
	detach_tween.tween_property(detach_highlighter, "color:a", 1.0, 1.0)
	detach_tween.tween_callback(func():
		detach_hover_done = true)


func _on_detach_area_mouse_exited() -> void:
	_detach_reset()
	

func _on_detach_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	 # TODO: rework the "topmost" mechanic to work for different draw/drag shapes (maybe just "interactable" in general?)
	 #and is_topmost_body_at_position(event.global_position)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if detach_hover_done:
			# do detach
			print("DETACH!")
			var new_sticky_note:StickyNoteFinal = STICKY_NOTE_FINAL.instantiate()
			new_sticky_note.position = position
			get_parent().add_child(new_sticky_note)
			
			# transfer image
			new_sticky_note.draw_component.texture_rect.texture = draw_component.texture_rect.texture
			new_sticky_note.draw_component.drawing_texture = draw_component.drawing_texture
			new_sticky_note.draw_component.drawing_image = draw_component.drawing_image
			
			# reset own image
			draw_component.setup_drawing_surface()
			
			# TODO ideally: have the mouse grab the newly created sticky note immediately, and not grab the current one anymore
			
		else:
			_detach_reset()

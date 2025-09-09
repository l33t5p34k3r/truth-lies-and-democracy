extends Area2D
class_name PencilTool

var is_held := false
var holder: Node2D
var original_position: Vector2

@onready var sprite: Sprite2D
@onready var collision_shape: CollisionShape2D

signal picked_up
signal dropped

func _ready():
	setup_pencil()
	input_pickable = true
	original_position = global_position

func setup_pencil():
	sprite = Sprite2D.new()
	add_child(sprite)
	
	collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 20)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	create_pencil_texture()

func create_pencil_texture():
	var pencil_image = Image.create(100, 20, false, Image.FORMAT_RGBA8)
	pencil_image.fill(Color.TRANSPARENT)
	
	for y in range(20):
		for x in range(100):
			var color: Color
			if x < 80:
				color = Color.SANDY_BROWN
			elif x < 90:
				color = Color.SILVER
			else:
				color = Color.DARK_GRAY
			pencil_image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(pencil_image)
	sprite.texture = texture

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_held:
			pick_up()

func _input(event):
	if is_held and event is InputEventMouseMotion:
		global_position = get_global_mouse_position()
	
	if is_held and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		drop()

func pick_up():
	is_held = true
	z_index = 100
	picked_up.emit()

func drop():
	is_held = false
	z_index = 0
	
	var paper = find_paper_at_position()
	if paper:
		enable_drawing_on_paper(paper)
	
	dropped.emit()

func find_paper_at_position() -> Paper:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1
	
	var results = space_state.intersect_point(query)
	for result in results:
		var body = result.collider
		if body.get_parent() is Paper:
			return body.get_parent()
	
	return null

func enable_drawing_on_paper(_paper: Paper):
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	
func return_to_original_position():
	global_position = original_position

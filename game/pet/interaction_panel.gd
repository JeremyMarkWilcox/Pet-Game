extends Control
## Action buttons that pop up when the pet is clicked.
## Hides after an action or a click anywhere else.

@export var pet: Pet


func _ready() -> void:
	hide()
	pet.clicked.connect(_on_pet_clicked)
	for node in find_children("*", "", true, false):
		if node is ActionButton:
			(node as ActionButton).pressed.connect(hide)


func _on_pet_clicked() -> void:
	visible = not visible
	if visible:
		_follow_pet()
		
		
func _process(_delta: float) -> void:
	if visible:
		_follow_pet()


## Sits centered under the pet's feet, kept on screen.
func _follow_pet() -> void:
	var screen := get_parent_area_size()
	var x := pet.position.x + (pet.size.x - size.x) * 0.5
	var y := pet.position.y + pet.size.y + 2.0
	position = Vector2(clampf(x, 0.0, screen.x - size.x), clampf(y, 0.0, screen.y - size.y))


func _input(event: InputEvent) -> void:
	# Close on a click outside both the panel and the pet. Doesn't consume the click.
	if not visible:
		return
	var click := event as InputEventMouseButton
	if click == null or not click.pressed:
		return
	if get_global_rect().has_point(click.position) or pet.get_global_rect().has_point(click.position):
		return
	hide()

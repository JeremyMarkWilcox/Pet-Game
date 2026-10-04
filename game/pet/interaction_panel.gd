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

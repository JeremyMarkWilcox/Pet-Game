extends Button
## Manual save, with a short "Saved!" confirmation so players know it worked.

@export var pet_save: PetSave
@export var saved_text := "Saved!"
@export_range(0.5, 5.0, 0.5, "suffix:s") var confirm_time := 1.5

var _normal_text := ""


func _ready() -> void:
	_normal_text = text
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if not pet_save.save_game():
		return
	text = saved_text
	disabled = true
	get_tree().create_timer(confirm_time).timeout.connect(_restore)


func _restore() -> void:
	text = _normal_text
	disabled = false

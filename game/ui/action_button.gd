class_name ActionButton
extends Button
## Triggers one pet action. One button per action; set action_id in the Inspector.

@export var action_id: StringName
@export var needs_system: NeedsSystem


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	needs_system.try_action(action_id)

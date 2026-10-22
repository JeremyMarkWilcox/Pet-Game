class_name Pet
extends Control
## The pet on screen: plays its animations, shows which need it's asking for and reacts to actions.

signal clicked

@export var needs_system: NeedsSystem
@export var sprite: AnimatedSprite2D
@export var need_bubble: Control
@export var need_icon: TextureRect
@export var need_label: Label ## Placeholder until need icons exist
## Animation played when an action is accepted. Refused actions play "decline".
@export var action_animations: Dictionary[StringName, StringName] = {
	&"feed": &"eat",
	&"play": &"play",
	&"pet": &"pet",
}


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.action_handled.connect(_on_action_handled)
	sprite.play(&"idle")
	_update_bubble()


func _gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
		accept_event()


func _on_need_changed(_id: StringName, _value: float) -> void:
	_update_bubble()


func _update_bubble() -> void:
	var need := _get_most_urgent_need()
	need_bubble.visible = need != null
	if need:
		need_icon.texture = need.icon
		need_label.text = String(need.id) if need.icon == null else ""


## The requested need with the lowest value, or null if the pet is content.
func _get_most_urgent_need() -> NeedData:
	var urgent: NeedData = null
	for need in needs_system.needs:
		if not needs_system.is_requesting(need.id):
			continue
		if urgent == null or needs_system.get_value(need.id) < needs_system.get_value(urgent.id):
			urgent = need
	return urgent


func _on_action_handled(action_id: StringName, accepted: bool) -> void:
	if accepted:
		sprite.play(action_animations.get(action_id, &"idle"))
	else:
		sprite.play(&"decline")


func _on_animation_finished() -> void:
	sprite.play(&"idle") # only one-shot animations (loop off) end

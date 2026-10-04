class_name Pet
extends Control
## The pet on screen: shows which need it's asking for and reacts to actions.
signal clicked

@export var needs_system: NeedsSystem
@export var body: Control ## The art; this is what hops and shakes
@export var need_bubble: Control
@export var need_icon: TextureRect
@export var need_label: Label ## Placeholder until need icons exist

var _body_rest := Vector2.ZERO
var _reaction_tween: Tween


func _ready() -> void:
	_body_rest = body.position
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.action_handled.connect(_on_action_handled)
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


func _on_action_handled(_action_id: StringName, accepted: bool) -> void:
	if accepted:
		_play_happy()
	else:
		_play_refuse()


func _play_happy() -> void:
	var tween := _start_reaction()
	tween.tween_property(body, "position:y", _body_rest.y - 8.0, 0.12) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(body, "position:y", _body_rest.y, 0.25) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _play_refuse() -> void:
	var tween := _start_reaction()
	for offset: float in [-3.0, 3.0, -2.0, 0.0]:
		tween.tween_property(body, "position:x", _body_rest.x + offset, 0.05)


func _start_reaction() -> Tween:
	if _reaction_tween:
		_reaction_tween.kill()
	body.position = _body_rest
	_reaction_tween = create_tween()
	return _reaction_tween

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

@export_group("Annoyance")
## Pokes and refused actions within the window before the pet growls.
@export var growl_threshold := 5
@export_range(1.0, 10.0, 0.5, "suffix:s") var annoyance_window := 4.0
@export var growl_sound: AudioStream ## Optional

var _annoyances: Array[float] = []
var _bubble_rest_x := 0.0

func _ready() -> void:
	_bubble_rest_x = need_bubble.position.x
	sprite.animation_finished.connect(_on_animation_finished)
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.action_handled.connect(_on_action_handled)
	sprite.play(&"idle")
	_update_bubble()
	
	
## True while a reaction plays (eat, play, pet, decline, growl).
func is_busy() -> bool:
	return sprite.animation != &"idle" and sprite.animation != &"walk"


## True while the pet is asking for a need (the bubble is showing).
func is_asking() -> bool:
	return _get_most_urgent_need() != null


func play_walk() -> void:
	sprite.play(&"walk")


func stop_walking() -> void:
	if sprite.animation == &"walk":
		sprite.play(&"idle")


## The art faces left; facing right mirrors it and moves the bubble to the other side of the head.
func set_facing_right(right: bool) -> void:
	sprite.flip_h = right
	if right:
		need_bubble.position.x = size.x - _bubble_rest_x - need_bubble.size.x
	else:
		need_bubble.position.x = _bubble_rest_x


func _gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
		accept_event()
		if _add_annoyance():
			_growl()


func _on_action_handled(action_id: StringName, accepted: bool) -> void:
	if accepted:
		sprite.play(action_animations.get(action_id, &"idle"))
	elif _add_annoyance():
		_growl()
	else:
		sprite.play(&"decline")


func _on_need_changed(_id: StringName, _value: float) -> void:
	_update_bubble()


func _update_bubble() -> void:
	var need := _get_most_urgent_need()
	need_bubble.visible = need != null
	if need:
		need_icon.texture = need.icon
	#need_label.text = String(need.id) if need.icon == null else ""


## The requested need with the lowest value, or null if the pet is content.
func _get_most_urgent_need() -> NeedData:
	var urgent: NeedData = null
	for need in needs_system.needs:
		if not needs_system.is_requesting(need.id):
			continue
		if urgent == null or needs_system.get_value(need.id) < needs_system.get_value(urgent.id):
			urgent = need
	return urgent


func _on_animation_finished() -> void:
	sprite.play(&"idle") # only one-shot animations (loop off) end


## Records a poke or a refused action. Returns true when it adds up to a growl.
func _add_annoyance() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	_annoyances.append(now)
	while now - _annoyances[0] > annoyance_window:
		_annoyances.pop_front()
	if _annoyances.size() < growl_threshold:
		return false
	_annoyances.clear()
	return true


func _growl() -> void:
	var anim := &"growl" if sprite.sprite_frames.has_animation(&"growl") else &"decline"
	sprite.play(anim)
	Shake.node_2d(sprite, 3.0) # skipped automatically if Screen Shake is off in Settings
	Audio.play_sfx(growl_sound, 0.1) # empty slot = silent

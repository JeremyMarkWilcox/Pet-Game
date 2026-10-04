extends Control

@export var music: AudioStream
@export var pause_menu: BaseMenu
@export var needs_system: NeedsSystem

var _last_window_size := Vector2i.ZERO


func _ready() -> void:
	Audio.play_music(music)
	Debug.win_requested.connect(_on_debug_win)
	Debug.lose_requested.connect(_on_debug_lose)
	if OS.has_feature("web"):
		_last_window_size = get_window().size
		get_window().size_changed.connect(_on_window_size_changed)


func _on_window_size_changed() -> void:
	var new_size := get_window().size
	# Leaving fullscreen (Esc in a browser) shrinks the window: pause.
	# Growing (entering fullscreen) doesn't pause.
	if new_size.x * new_size.y < _last_window_size.x * _last_window_size.y \
			and not MenuManager.is_menu_open():
		MenuManager.open_menu(pause_menu)
	_last_window_size = new_size


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not MenuManager.is_menu_open():
		MenuManager.open_menu(pause_menu)
		get_viewport().set_input_as_handled()
	

func _on_debug_win() -> void:
	needs_system.add_to_all(1.0) # Page Up: refill everything


func _on_debug_lose() -> void:
	needs_system.add_to_all(-0.3) # Page Down: drain 30%

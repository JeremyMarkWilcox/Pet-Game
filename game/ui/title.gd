extends Control

@export_file("*.tscn") var game_scene: String
@export var music: AudioStream
@export var play_button: Button
@export var settings_button: Button
@export var credits_button: Button
@export var quit_button: Button
@export var settings_menu: BaseMenu
@export var credits_menu: BaseMenu
@export var version_label: Label
## Optional: these fade in when the title opens (e.g. the logo and the button column).
@export var menu_items: Array[CanvasItem] = []
@export var fade_in_time := 0.8

var _loaded_game: PackedScene  # keeps the preloaded game scene alive until Play


func _ready() -> void:
	Audio.play_music(music)
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(func() -> void: MenuManager.open_menu(settings_menu))
	credits_button.pressed.connect(func() -> void: MenuManager.open_menu(credits_menu))
	quit_button.pressed.connect(SceneManager.quit)
	quit_button.visible = not OS.has_feature("web")  # browsers can't close the tab
	MenuManager.menu_closed.connect(_on_menu_closed)
	play_button.grab_focus()
	var version: String = ProjectSettings.get_setting("application/config/version", "")
	version_label.text = "v" + version if version else ""
	ResourceLoader.load_threaded_request(game_scene)  # load the game while the player is on the title
	_fade_in_menu()


func _on_play_pressed() -> void:
	play_button.disabled = true  # no double starts while the scene loads
	_loaded_game = ResourceLoader.load_threaded_get(game_scene)  # waits only if it isn't done yet
	SceneManager.change_scene(game_scene)


func _on_menu_closed(_menu: BaseMenu) -> void:
	if not MenuManager.is_menu_open():
		play_button.grab_focus()


func _fade_in_menu() -> void:
	if menu_items.is_empty():
		return
	var tween := create_tween().set_parallel(true)
	for item: CanvasItem in menu_items:
		item.modulate.a = 0.0
		tween.tween_property(item, "modulate:a", 1.0, fade_in_time)

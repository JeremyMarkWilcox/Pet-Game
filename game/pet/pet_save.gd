class_name PetSave
extends Node
## Saves and loads the pet as JSON in user:// (on web: the browser's storage).
## Saves on a timer, on focus loss, on leaving the scene, and via save_game() for a manual button.

signal saved

const SAVE_PATH := "user://pet_save.json"
const SAVE_VERSION := 1

@export var needs_system: NeedsSystem
@export var bond_system: BondSystem
@export_range(5.0, 300.0, 5.0, "suffix:s") var autosave_interval: float = 30.0

var _time_since_save := 0.0


func _ready() -> void:
	load_game()


func _process(delta: float) -> void:
	_time_since_save += delta
	if _time_since_save >= autosave_interval:
		save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


func _exit_tree() -> void:
	save_game()


func save_game() -> void:
	_time_since_save = 0.0
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"needs": needs_system.get_save_data(),
		"bond": bond_system.get_save_data(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("PetSave: could not write %s (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	saved.emit()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return # first visit: needs start full
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not parsed is Dictionary:
		push_warning("PetSave: save file unreadable, starting fresh")
		return
	var data: Dictionary = parsed
	var now := Time.get_unix_time_from_system()
	var seconds_away := maxf(0.0, now - float(data.get("saved_at", now)))
	needs_system.load_save_data(data.get("needs", {}), seconds_away)
	bond_system.load_save_data(float(data.get("bond", 0.0)), seconds_away)

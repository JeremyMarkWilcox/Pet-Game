class_name PetHints
extends Node
## First-time hints for this game. Which hints were seen is stored in the pet save,
## so each hint shows once per pet, not once per session.

const HINTS := {
	&"save": ["Your pet lives in this browser",
		"Your pet is saved automatically, in this browser on this device. Clearing your browser data, playing in a private window or switching browsers starts a new pet."],
	&"click_pet": ["Say hello!",
		"Click your pet to feed it, play with it or pet it."],
	&"bond": ["Building your bond",
		"Caring for your pet fills the Bond bar. Help it when it asks for something to fill it faster."],
}

@export var hint_card: HintCard
@export var pet: Pet
@export var needs_system: NeedsSystem
## Time to explore before the "click your pet" hint appears. Clicking the pet first skips it.
@export_range(0.0, 120.0, 1.0, "suffix:s") var click_hint_delay := 25.0

var _seen: Dictionary[StringName, bool] = {}
var _pending: Array[StringName] = []


func _ready() -> void:
	pet.clicked.connect(_on_pet_clicked)
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.need_satisfied.connect(_on_need_satisfied)
	_queue(&"save")
	if not _seen.has(&"click_pet"):
		# false = the timer pauses while the game is paused (e.g. while the save hint is open)
		get_tree().create_timer(click_hint_delay, false).timeout.connect(_queue.bind(&"click_pet"))


func _process(_delta: float) -> void:
	# Shows queued hints one at a time, whenever no other menu is open.
	if _pending.is_empty() or MenuManager.is_menu_open():
		return
	var id: StringName = _pending.pop_front()
	if _seen.has(id):
		return
	_seen[id] = true
	hint_card.show_hint(HINTS[id][0], HINTS[id][1])


func _queue(id: StringName) -> void:
	if not _seen.has(id) and not _pending.has(id):
		_pending.append(id)


func _on_pet_clicked() -> void:
	_seen[&"click_pet"] = true # they found it on their own: never show it
	_pending.erase(&"click_pet")


func _on_need_changed(_id: StringName, _value: float) -> void:
	if pet.is_asking():
		_queue(&"bond")


func _on_need_satisfied(_id: StringName, _restored: float, _was_requested: bool) -> void:
	_queue(&"bond")


func get_save_data() -> Array:
	return _seen.keys()


func load_save_data(ids: Array) -> void:
	for id in ids:
		_seen[StringName(id)] = true

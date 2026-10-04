class_name NeedsSystem
extends Node
## Ticks the pet's needs on real clock time. Values run from 1.0 (full) to 0.0 (empty).

signal need_changed(id: StringName, value: float)
signal action_handled(action_id: StringName, accepted: bool)

const TICK_INTERVAL := 1.0 ## Seconds between updates

@export var needs: Array[NeedData] = []

var _values: Dictionary[StringName, float] = {}
var _needs_by_id: Dictionary[StringName, NeedData] = {}
var _last_tick := 0.0


func _ready() -> void:
	for need in needs:
		if need.id == &"":
			push_warning("NeedsSystem: a NeedData has no id: %s" % need.resource_path)
		_needs_by_id[need.id] = need
		if not _values.has(need.id):
			_values[need.id] = 1.0
	_last_tick = Time.get_unix_time_from_system()


func _process(_delta: float) -> void:
	# Real clock time, not delta: browsers slow down background tabs and pausing stops _process.
	var now := Time.get_unix_time_from_system()
	var elapsed := now - _last_tick
	if elapsed < TICK_INTERVAL:
		return
	_last_tick = now
	for need in needs:
		_set_value(need.id, get_value(need.id) - need.get_decay_per_second() * elapsed)


func get_value(id: StringName) -> float:
	return _values.get(id, 0.0)


func is_requesting(id: StringName) -> bool:
	var need: NeedData = _needs_by_id.get(id)
	return need != null and get_value(id) < need.request_threshold


func satisfy(id: StringName) -> void:
	var need: NeedData = _needs_by_id.get(id)
	if need:
		_set_value(id, get_value(id) + need.satisfy_amount)
		
		
## Tries an action (e.g. &"feed"). Only counts if the matching need is low enough to be requested.
func try_action(action_id: StringName) -> bool:
	for need in needs:
		if need.action_id == action_id and is_requesting(need.id):
			satisfy(need.id)
			action_handled.emit(action_id, true)
			return true
	action_handled.emit(action_id, false)
	return false


## Testing helper: adds amount (negative drains) to every need.
func add_to_all(amount: float) -> void:
	for need in needs:
		_set_value(need.id, get_value(need.id) + amount)


func get_save_data() -> Dictionary:
	var data := {}
	for id in _values:
		data[String(id)] = _values[id]
	return data


func load_save_data(data: Dictionary, seconds_away: float) -> void:
	for need in needs:
		var value: float = data.get(String(need.id), 1.0)
		var offline_loss := need.get_decay_per_second() * need.offline_rate_multiplier * seconds_away
		var lowest := minf(value, need.offline_floor) # never raise a need that was already below the floor
		_set_value(need.id, maxf(value - offline_loss, lowest))
	_last_tick = Time.get_unix_time_from_system()


func _set_value(id: StringName, value: float) -> void:
	_values[id] = clampf(value, 0.0, 1.0)
	need_changed.emit(id, _values[id])

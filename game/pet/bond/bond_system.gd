class_name BondSystem
extends Node
## The friendship meter, 0.0 to 1.0. Grows when an action matches what the pet needs.
## Drains slowly while the pet has an unmet need.

signal bond_changed(value: float)

const TICK_INTERVAL := 1.0 ## Seconds between updates

@export var needs_system: NeedsSystem
@export_range(0.0, 1.0, 0.01) var gain_per_need_point: float = 0.1 ## Bond per 100% of need restored
@export_range(1.0, 3.0, 0.1) var requested_bonus: float = 1.5 ## Multiplier when the pet was asking for it

@export_group("Decay")
@export_range(1.0, 168.0, 1.0, "suffix:h") var hours_full_to_empty: float = 48.0 ## While the pet has an unmet need
@export_range(0.0, 1.0, 0.05) var content_decay_multiplier: float = 0.0 ## Drain while all needs are fine (0 = none)
@export_range(0.0, 1.0, 0.05) var offline_rate_multiplier: float = 0.25
@export_range(0.0, 1.0, 0.05) var offline_floor: float = 0.0 ## Never drops below this while closed

var _bond := 0.0
var _last_tick := 0.0


func _ready() -> void:
	needs_system.need_satisfied.connect(_on_need_satisfied)
	_last_tick = Time.get_unix_time_from_system()


func _process(_delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	var elapsed := now - _last_tick
	if elapsed < TICK_INTERVAL:
		return
	_last_tick = now
	var rate := _get_decay_per_second()
	if not _has_unmet_need():
		rate *= content_decay_multiplier
	if rate > 0.0:
		_set_bond(_bond - rate * elapsed)


func get_bond() -> float:
	return _bond


func get_save_data() -> float:
	return _bond


func load_save_data(saved_bond: float, seconds_away: float) -> void:
	var offline_loss := _get_decay_per_second() * offline_rate_multiplier * seconds_away
	_set_bond(maxf(saved_bond - offline_loss, minf(saved_bond, offline_floor)))
	_last_tick = Time.get_unix_time_from_system()


# Grows with every bit of need the player restores.
func _on_need_satisfied(_id: StringName, restored: float, was_requested: bool) -> void:
	var gain := restored * gain_per_need_point
	if was_requested:
		gain *= requested_bonus
	_set_bond(_bond + gain)


func _has_unmet_need() -> bool:
	for need in needs_system.needs:
		if needs_system.is_requesting(need.id):
			return true
	return false


func _get_decay_per_second() -> float:
	return 1.0 / (hours_full_to_empty * 3600.0)


func _set_bond(new_value: float) -> void:
	_bond = clampf(new_value, 0.0, 1.0)
	bond_changed.emit(_bond)

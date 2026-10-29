extends Label
## TEMPORARY: shows need values until the real need bubbles exist.

@export var needs_system: NeedsSystem
@export var bond_system: BondSystem

var _last_reaction := ""


func _ready() -> void:
	visible = OS.is_debug_build()
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.action_handled.connect(_on_action_handled)
	bond_system.bond_changed.connect(func(_value: float) -> void: _refresh())
	_refresh()


func _on_need_changed(_id: StringName, _value: float) -> void:
	_refresh()
	
	
func _on_action_handled(action_id: StringName, accepted: bool) -> void:
	_last_reaction = "%s: %s" % [action_id, "yes!" if accepted else "not now"]
	_refresh()


func _refresh() -> void:
	var lines: PackedStringArray = []
	for need in needs_system.needs:
		lines.append("%s: %d%%" % [need.id, roundi(needs_system.get_value(need.id) * 100.0)])
	lines.append("bond: %d%%" % roundi(bond_system.get_bond() * 100.0))
	if _last_reaction != "":
		lines.append(_last_reaction)
	text 	= "\n".join(lines)

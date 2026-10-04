extends Label
## TEMPORARY: shows need values until the real need bubbles exist.

@export var needs_system: NeedsSystem
@export var _last_reaction := ""

func _ready() -> void:
	needs_system.need_changed.connect(_on_need_changed)
	needs_system.action_handled.connect(_on_action_handled)
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
	if _last_reaction != "":
		lines.append(_last_reaction)
	text 	= "\n".join(lines)

extends VBoxContainer
## Always-visible status: the bond bar plus one small bar per need, built from NeedsSystem's list.

@export var needs_system: NeedsSystem
@export var bond_system: BondSystem
@export var bond_bar: ProgressBar
@export var need_bar_size := Vector2(48, 8)

var _need_bars: Dictionary[StringName, ProgressBar] = {}


func _ready() -> void:
	for need in needs_system.needs:
		_add_need_row(need)
	needs_system.need_changed.connect(_on_need_changed)
	bond_system.bond_changed.connect(_on_bond_changed)
	_on_bond_changed(bond_system.get_bond())


func _add_need_row(need: NeedData) -> void:
	var row := HBoxContainer.new()
	var icon := TextureRect.new()
	icon.texture = need.icon
	icon.custom_minimum_size = Vector2(16, 16)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	var bar := ProgressBar.new()
	bar.max_value = 1.0
	bar.step = 0.0
	bar.show_percentage = false
	bar.custom_minimum_size = need_bar_size
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.value = needs_system.get_value(need.id)
	row.add_child(icon)
	row.add_child(bar)
	add_child(row)
	_need_bars[need.id] = bar


func _on_need_changed(id: StringName, value: float) -> void:
	if _need_bars.has(id):
		_need_bars[id].value = value


func _on_bond_changed(value: float) -> void:
	bond_bar.value = value

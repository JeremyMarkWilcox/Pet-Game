class_name NeedData
extends Resource
## One pet need (hunger, boredom...). All tuning happens in the Inspector.
## Needs run from 1.0 (full) to 0.0 (empty).

@export var id: StringName
@export var action_id: StringName ## The action that satisfies this need, e.g. &"feed"
@export var icon: Texture2D ## Shown in the need bubble (no text)

@export_group("Decay")
@export_range(0.5, 24.0, 0.5, "suffix:h") var hours_full_to_empty: float = 4.0
@export_range(0.0, 1.0, 0.05) var offline_rate_multiplier: float = 0.25 ## Slower decay while the tab is closed
@export_range(0.0, 1.0, 0.05) var offline_floor: float = 0.2 ## Never drops below this while closed

@export_group("Behavior")
@export_range(0.0, 1.0, 0.05) var start_value: float = 0.5 ## Value for a brand-new pet
@export_range(0.0, 1.0, 0.05) var request_threshold: float = 0.4 ## Below this, the pet asks for it
@export_range(0.0, 1.0, 0.05) var satisfy_amount: float = 0.5
@export_range(0.5, 1.0, 0.05) var accept_below: float = 0.9 ## Actions are accepted while the need is below this


func get_decay_per_second() -> float:
	return 1.0 / (hours_full_to_empty * 3600.0)

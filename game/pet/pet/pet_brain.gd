extends Node
class_name PetBrain
## Decides what the pet does on its own: sit for a while, walk to a random spot, repeat.
## Holds still while roaming is off, while the pet asks for something, during reactions,
## and for a moment after it's clicked.

enum State { IDLE, WALK }

@export var pet: Pet
@export_range(5.0, 120.0, 1.0, "suffix:px/s") var walk_speed := 30.0
@export_range(0.5, 30.0, 0.5, "suffix:s") var idle_time_min := 3.0
@export_range(0.5, 30.0, 0.5, "suffix:s") var idle_time_max := 8.0
@export_range(0.0, 600.0, 10.0, "suffix:px") var min_walk_distance := 80.0
@export_range(0.0, 200.0, 1.0, "suffix:px") var edge_margin := 8.0
## How long the pet stays put after being clicked.
@export_range(0.0, 30.0, 0.5, "suffix:s") var attention_time := 8.0

## Turned off by things like the future focus timer.
var roaming_enabled := true

var _state := State.IDLE
var _idle_left := 0.0
var _target_x := 0.0


func _ready() -> void:
	pet.clicked.connect(_on_pet_clicked)
	_idle_left = randf_range(idle_time_min, idle_time_max)


func _process(delta: float) -> void:
	if not _can_move():
		_hold()
		return
	match _state:
		State.IDLE:
			_idle_left -= delta
			if _idle_left <= 0.0:
				_start_walk()
		State.WALK:
			_walk(delta)


func _can_move() -> bool:
	return roaming_enabled and not pet.is_busy() and not pet.is_asking()


func _start_walk() -> void:
	var min_x := edge_margin
	var max_x := pet.get_parent_area_size().x - pet.size.x - edge_margin
	if max_x <= min_x:
		_idle_left = idle_time_max
		return
	for attempt in 5: # try a few times to find a spot that's worth walking to
		_target_x = randf_range(min_x, max_x)
		if absf(_target_x - pet.position.x) >= min_walk_distance:
			break
	_state = State.WALK
	pet.set_facing_right(_target_x > pet.position.x)
	pet.play_walk()


func _walk(delta: float) -> void:
	var step := walk_speed * delta
	var distance := _target_x - pet.position.x
	if absf(distance) <= step:
		pet.position.x = _target_x
		_finish_walk()
	else:
		pet.position.x += signf(distance) * step


func _finish_walk() -> void:
	_state = State.IDLE
	_idle_left = randf_range(idle_time_min, idle_time_max)
	pet.stop_walking()


## Stop mid-walk without cutting off a reaction animation.
func _hold() -> void:
	if _state == State.WALK:
		_finish_walk()


func _on_pet_clicked() -> void:
	_hold()
	_idle_left = maxf(_idle_left, attention_time)
	# Face the side that was clicked: tail side = turn around, head side = stay.
	pet.set_facing_right(pet.get_local_mouse_position().x > pet.size.x * 0.5)

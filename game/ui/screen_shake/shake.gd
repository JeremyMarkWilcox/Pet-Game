class_name Shake
## Shake helpers. Every call checks Settings.screen_shake first, so turning
## Screen Shake off in Settings turns it off everywhere.
##
##   Shake.control(health_panel)      # a UI element (must NOT be inside a container)
##   Shake.node_2d(sprite, 4.0)
##   Shake.node_3d(model, 0.1)
##   Shake.camera_2d(camera, 8.0)     # the whole 2D view
##   Shake.camera_3d(camera, 0.15)    # the whole 3D view
##
## Calling it again mid-shake restarts from the node's true resting place,
## so repeated hits never make it drift.

## How many jolts per shake. Each is weaker than the last.
const STEPS := 5
## Seconds per jolt. STEPS * STEP_TIME is roughly how long a shake lasts.
const STEP_TIME := 0.03
## Each jolt is this fraction of the one before (0.6 = 40% weaker).
const FALLOFF := 0.6
const META := &"_shake"


## Strength in pixels.
static func control(node: Control, strength := 6.0) -> void:
	_shake(node, node.position, strength, func(v: Vector2) -> void: node.position = v)


## Strength in pixels.
static func node_2d(node: Node2D, strength := 4.0) -> void:
	_shake(node, node.position, strength, func(v: Vector2) -> void: node.position = v)


## Strength in meters. Shakes left/right and up/down.
static func node_3d(node: Node3D, strength := 0.1) -> void:
	_shake(node, Vector2(node.position.x, node.position.y), strength, _set_node_3d.bind(node))


## Strength in pixels. Uses the camera's offset, so following still works.
static func camera_2d(camera: Camera2D, strength := 8.0) -> void:
	_shake(camera, camera.offset, strength, func(v: Vector2) -> void: camera.offset = v)


## Strength in meters. Uses h_offset/v_offset, so the camera node itself never moves.
static func camera_3d(camera: Camera3D, strength := 0.15) -> void:
	_shake(camera, Vector2(camera.h_offset, camera.v_offset), strength, _set_camera_3d.bind(camera))


static func _shake(node: Node, current: Vector2, strength: float, apply: Callable) -> void:
	if node == null or strength <= 0.0 or not Settings.screen_shake:
		return
	var rest := current
	if node.has_meta(META):
		var running: Dictionary = node.get_meta(META)
		var old_tween := running["tween"] as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
		rest = running["rest"]  # mid-shake: return to the real resting place
	var tween := node.create_tween()
	node.set_meta(META, {"tween": tween, "rest": rest})
	var from := rest
	var amount := strength
	for i in STEPS:
		var to := rest + Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tween.tween_method(apply, from, to, STEP_TIME)
		from = to
		amount *= FALLOFF
	tween.tween_method(apply, from, rest, STEP_TIME)
	tween.tween_callback(func() -> void: node.remove_meta(META))


static func _set_node_3d(v: Vector2, node: Node3D) -> void:
	node.position.x = v.x
	node.position.y = v.y


static func _set_camera_3d(v: Vector2, camera: Camera3D) -> void:
	camera.h_offset = v.x
	camera.v_offset = v.y

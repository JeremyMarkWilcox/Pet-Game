class_name HintCard
extends BaseMenu
## A short tutorial card. MenuManager pauses the game while it's open; Got it or Esc closes it.
## Call show_once() from game code at the moment a hint is needed.

@export var title_label: Label
@export var body_label: RichTextLabel
@export var got_it_button: Button

# Static, so it survives SceneManager reloading the game scene on restart.
static var _seen: Dictionary[StringName, bool] = {}


func _ready() -> void:
	super()
	got_it_button.pressed.connect(MenuManager.close_menu)


## Shows the hint the first time this id comes up in a session. Skipped if
## another menu is already open. Returns true if it was shown.
func show_once(id: StringName, title: String, body: String) -> bool:
	if _seen.has(id) or MenuManager.is_menu_open():
		return false
	_seen[id] = true
	show_hint(title, body)
	return true


## Shows the hint every time (no once-only check).
func show_hint(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	MenuManager.open_menu(self)

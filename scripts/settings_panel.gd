extends Control
## Settings overlay shared by the main menu and the pause menu. Writes straight
## to the App autoload, which persists the values.

signal closed

@onready var shadows_toggle: CheckButton = %ShadowsToggle
@onready var back_button: Button = %BackButton


func _ready() -> void:
	shadows_toggle.button_pressed = App.shadows
	shadows_toggle.toggled.connect(func(on: bool) -> void: App.shadows = on)
	back_button.pressed.connect(close)


func open() -> void:
	shadows_toggle.button_pressed = App.shadows
	visible = true


func close() -> void:
	visible = false
	closed.emit()

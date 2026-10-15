extends Control
## Main menu: new game, continue from the single save slot, settings, quit.

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_panel: Control = %SettingsPanel
@onready var centre: Control = $Centre


func _ready() -> void:
	continue_button.disabled = not SaveGame.exists()
	new_game_button.pressed.connect(App.new_game)
	continue_button.pressed.connect(App.continue_game)
	settings_button.pressed.connect(_open_settings)
	settings_panel.closed.connect(func() -> void: centre.visible = true)
	quit_button.pressed.connect(get_tree().quit)


func _open_settings() -> void:
	centre.visible = false
	settings_panel.open()

extends Node
## Autoload "App": persisted settings and scene flow between the menu and the garden.

signal settings_changed

const SETTINGS_PATH := "user://settings.cfg"
const MENU_SCENE := "res://scenes/main_menu.tscn"
const GARDEN_SCENE := "res://scenes/garden.tscn"

## Draw the Minifantasy shadow layers under characters, fences and props.
var shadows := true:
	set(value):
		if shadows == value:
			return
		shadows = value
		save_settings()
		settings_changed.emit()

## Set by continue_game() so the garden loads the save when it starts.
var load_on_start := false


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	shadows = bool(config.get_value("display", "shadows", true))


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "shadows", shadows)
	config.save(SETTINGS_PATH)


func new_game() -> void:
	load_on_start = false
	get_tree().change_scene_to_file(GARDEN_SCENE)


func continue_game() -> void:
	load_on_start = true
	get_tree().change_scene_to_file(GARDEN_SCENE)


func go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

extends SceneTree
## Headless sanity check run by CI:
##   godot --headless --path . --script tests/ci_check.gd
## Loads the main scene and every .gd script under scripts/ so parse errors fail the build.


func _initialize() -> void:
	var failures := 0
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	if not ResourceLoader.exists(main_scene):
		push_error("Main scene missing: %s" % main_scene)
		failures += 1
	elif load(main_scene) == null:
		push_error("Main scene failed to load: %s" % main_scene)
		failures += 1

	for path in _collect_scripts("res://scripts"):
		var script := load(path) as GDScript
		if script == null or not script.can_instantiate():
			push_error("Script failed to load: %s" % path)
			failures += 1

	if failures > 0:
		printerr("ci_check: %d failure(s)" % failures)
		quit(1)
	else:
		print("ci_check: ok")
		quit(0)


func _collect_scripts(dir_path: String) -> PackedStringArray:
	var found := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		var full := dir_path.path_join(name)
		if dir.current_is_dir():
			found.append_array(_collect_scripts(full))
		elif name.ends_with(".gd"):
			found.append(full)
		name = dir.get_next()
	return found

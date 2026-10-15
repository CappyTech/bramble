extends SceneTree
## Headless round-trip test for SaveGame:
##   godot --headless --path . --script tests/test_save.gd

const TEST_PATH := "user://test_save.json"

var _failures := 0


func _initialize() -> void:
	_test_round_trip()
	_test_missing_and_corrupt()
	SaveGame.delete(TEST_PATH)
	if _failures > 0:
		printerr("test_save: %d failure(s)" % _failures)
		quit(1)
	else:
		print("test_save: ok")
		quit(0)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)


func _test_round_trip() -> void:
	var plot := Allotment.new(3, 2)
	plot.plant(0, 0, CropLibrary.find(&"potato"))
	plot.water(0, 0)
	plot.sleep()
	plot.plant(2, 1, CropLibrary.find(&"radish"))
	for i in 3:
		plot.water(2, 1)
		plot.sleep()
	plot.harvest(2, 1)
	plot.water(1, 0)
	_check(SaveGame.write(plot, TEST_PATH), "write succeeds")
	_check(SaveGame.exists(TEST_PATH), "file exists after write")
	var loaded := SaveGame.read(TEST_PATH)
	_check(loaded != null, "read returns an allotment")
	if loaded == null:
		return
	_check(loaded.day == plot.day, "day restored")
	_check(loaded.width == 3 and loaded.height == 2, "grid size restored")
	var tile := loaded.tile_at(0, 0)
	_check(tile.crop != null and tile.crop.id == &"potato", "crop restored")
	_check(tile.state == PlotTile.State.GROWING, "state restored")
	_check(tile.stage == plot.tile_at(0, 0).stage, "stage restored")
	_check(tile.days_in_stage == plot.tile_at(0, 0).days_in_stage, "days in stage restored")
	_check(loaded.tile_at(1, 0).watered, "watered flag restored")
	_check(loaded.tile_at(2, 1).state == PlotTile.State.EMPTY, "harvested tile empty")
	_check(loaded.harvested.get(&"radish", 0) == 3, "harvest tally restored")


func _test_missing_and_corrupt() -> void:
	SaveGame.delete(TEST_PATH)
	_check(not SaveGame.exists(TEST_PATH), "deleted file no longer exists")
	_check(SaveGame.read(TEST_PATH) == null, "missing file reads as null")
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("not json")
	file = null
	_check(SaveGame.read(TEST_PATH) == null, "corrupt file reads as null")

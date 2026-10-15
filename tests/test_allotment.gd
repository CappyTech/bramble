extends SceneTree
## Headless unit test for the allotment model:
##   godot --headless --path . --script tests/test_allotment.gd

var _failures := 0


func _initialize() -> void:
	_test_plant_and_occupied()
	_test_growth_requires_water()
	_test_matures_and_harvests()
	_test_sleep_advances_day_and_dries()
	if _failures > 0:
		printerr("test_allotment: %d failure(s)" % _failures)
		quit(1)
	else:
		print("test_allotment: ok")
		quit(0)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)


func _test_plant_and_occupied() -> void:
	var plot := Allotment.new(2, 2)
	var radish := CropLibrary.find(&"radish")
	_check(radish != null, "radish exists in library")
	_check(plot.plant(0, 0, radish), "planting on empty tile succeeds")
	_check(not plot.plant(0, 0, radish), "planting on occupied tile fails")
	_check(not plot.plant(1, 1, null), "planting null crop fails")
	_check(plot.tile_at(0, 0).state == PlotTile.State.GROWING, "planted tile is growing")


func _test_growth_requires_water() -> void:
	var plot := Allotment.new(1, 1)
	plot.plant(0, 0, CropLibrary.find(&"radish"))
	plot.sleep()
	_check(plot.tile_at(0, 0).stage == 0, "unwatered plant does not advance")
	plot.water(0, 0)
	_check(not plot.water(0, 0), "watering twice in one day is rejected")
	plot.sleep()
	_check(plot.tile_at(0, 0).stage == 1, "watered plant advances a stage")


func _test_matures_and_harvests() -> void:
	var plot := Allotment.new(1, 1)
	var potato := CropLibrary.find(&"potato")
	plot.plant(0, 0, potato)
	_check(plot.harvest(0, 0) == 0, "harvesting an unripe plant yields nothing")
	for i in potato.total_days() - 1:
		plot.water(0, 0)
		plot.sleep()
	_check(plot.tile_at(0, 0).state == PlotTile.State.GROWING, "not mature one day early")
	plot.water(0, 0)
	plot.sleep()
	var tile := plot.tile_at(0, 0)
	_check(tile.state == PlotTile.State.MATURE, "mature after total_days watered days")
	_check(is_equal_approx(tile.growth_fraction(), 1.0), "growth fraction is 1 when mature")
	_check(plot.harvest(0, 0) == potato.yield_amount, "harvest returns the crop yield")
	_check(tile.state == PlotTile.State.EMPTY, "harvested tile is empty")
	_check(plot.harvested[&"potato"] == potato.yield_amount, "harvest tally recorded")
	_check(plot.total_harvested() == potato.yield_amount, "total harvested matches")


func _test_sleep_advances_day_and_dries() -> void:
	var plot := Allotment.new(1, 1)
	plot.water(0, 0)
	_check(plot.day == 1, "starts on day 1")
	plot.sleep()
	_check(plot.day == 2, "sleep advances the day")
	_check(not plot.tile_at(0, 0).watered, "tiles dry out overnight")

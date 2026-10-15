class_name Allotment
extends RefCounted
## The player's plot: a grid of PlotTiles plus the day counter and harvest tally.
## Days advance only through sleep(); how time passes within a day is undecided
## and deliberately not modelled here.

signal changed

var width: int
var height: int
var day: int = 1
## Crop id -> total units harvested so far.
var harvested: Dictionary = {}
var _tiles: Array[PlotTile] = []


func _init(grid_width: int, grid_height: int) -> void:
	width = grid_width
	height = grid_height
	for i in width * height:
		_tiles.append(PlotTile.new())


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


func tile_at(x: int, y: int) -> PlotTile:
	return _tiles[y * width + x]


func plant(x: int, y: int, def: CropDef) -> bool:
	var ok := tile_at(x, y).plant(def)
	if ok:
		changed.emit()
	return ok


func water(x: int, y: int) -> bool:
	var ok := tile_at(x, y).water()
	if ok:
		changed.emit()
	return ok


func harvest(x: int, y: int) -> int:
	var tile := tile_at(x, y)
	var id := tile.crop.id if tile.crop != null else &""
	var amount := tile.harvest()
	if amount > 0:
		harvested[id] = int(harvested.get(id, 0)) + amount
		changed.emit()
	return amount


## End the day: every tile advances, then the calendar moves on.
func sleep() -> void:
	for tile in _tiles:
		tile.end_day()
	day += 1
	changed.emit()


func total_harvested() -> int:
	var total := 0
	for amount in harvested.values():
		total += int(amount)
	return total

class_name SaveGame
extends RefCounted
## Serialises the Allotment to JSON in user://. One slot for now.

const PATH := "user://save.json"
const VERSION := 1


static func exists(path: String = PATH) -> bool:
	return FileAccess.file_exists(path)


static func delete(path: String = PATH) -> void:
	if exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func write(allotment: Allotment, path: String = PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveGame: cannot write %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(JSON.stringify(to_dict(allotment), "\t"))
	return true


## Returns null when there is no readable save.
static func read(path: String = PATH) -> Allotment:
	if not exists(path):
		return null
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if data is not Dictionary:
		push_error("SaveGame: %s is not valid JSON" % path)
		return null
	return from_dict(data)


static func to_dict(allotment: Allotment) -> Dictionary:
	var tiles: Array = []
	for y in allotment.height:
		for x in allotment.width:
			var tile := allotment.tile_at(x, y)
			tiles.append({
				"crop": String(tile.crop.id) if tile.crop != null else "",
				"state": tile.state,
				"stage": tile.stage,
				"days_in_stage": tile.days_in_stage,
				"watered": tile.watered,
				"soil": tile.soil,
			})
	var harvested := {}
	for id in allotment.harvested:
		harvested[String(id)] = allotment.harvested[id]
	return {
		"version": VERSION,
		"day": allotment.day,
		"width": allotment.width,
		"height": allotment.height,
		"harvested": harvested,
		"tiles": tiles,
	}


static func from_dict(data: Dictionary) -> Allotment:
	var width := int(data.get("width", 0))
	var height := int(data.get("height", 0))
	if width <= 0 or height <= 0:
		push_error("SaveGame: bad grid size")
		return null
	var allotment := Allotment.new(width, height)
	allotment.day = int(data.get("day", 1))
	var harvested: Dictionary = data.get("harvested", {})
	for id in harvested:
		allotment.harvested[StringName(id)] = int(harvested[id])
	var tiles: Array = data.get("tiles", [])
	for i in mini(tiles.size(), width * height):
		var entry: Dictionary = tiles[i]
		var tile := allotment.tile_at(i % width, i / width)
		var crop_id := String(entry.get("crop", ""))
		tile.crop = CropLibrary.find(StringName(crop_id)) if crop_id != "" else null
		tile.state = int(entry.get("state", PlotTile.State.EMPTY)) as PlotTile.State
		if tile.crop == null and tile.state != PlotTile.State.EMPTY:
			tile.state = PlotTile.State.EMPTY
		tile.stage = int(entry.get("stage", 0))
		tile.days_in_stage = int(entry.get("days_in_stage", 0))
		tile.watered = bool(entry.get("watered", false))
		tile.soil = entry.get("soil", {})
	return allotment

class_name AllotmentView
extends Control
## Draws the allotment grid and turns taps into actions.
## Uses the Minifantasy Farm and Forgotten Plains sheets when they are on disk
## (assets/minifantasy is gitignored, see its README) and falls back to coloured
## shapes otherwise, so CI and fresh checkouts still run.

enum Tool { PLANT, WATER, HARVEST }

## 8 px source pixels drawn at 8x: a 10x7 tile view (plot plus border) fits 1280x720.
const PIXEL_SCALE := 8
const TILE_SIZE := 8 * PIXEL_SCALE
## Grass tiles drawn around the plot.
const BORDER := 1

const SOIL_DRY := Color(0.45, 0.31, 0.2)
const SOIL_WET := Color(0.3, 0.2, 0.14)
const GRASS := Color(0.42, 0.6, 0.25)
const GRID_LINE := Color(0.2, 0.13, 0.08)
const RIPE_RING := Color(1.0, 0.9, 0.3)

const MINIFANTASY_DIR := "res://assets/minifantasy/"
const FARM_TILESET := MINIFANTASY_DIR + "farm/Minifantasy_Farm_v3.0/Minifantasy_Farm_Assets/Tileset/Minifantasy_FarmTileset.png"
const CROP_SHEET := MINIFANTASY_DIR + "farm/Minifantasy_Farm_v3.0/Minifantasy_Farm_Assets/Crops/Minifantasy_FarmSeedsAndCrops.png"
const PLAINS_TILESET := MINIFANTASY_DIR + "forgotten_plains/Minifantasy_ForgottenPlains_v3.6_Commercial_Version/Minifantasy_ForgottenPlains_Assets/Tileset/Minifantasy_ForgottenPlainsTiles.png"

## Ploughed-field tiles on the farm sheet, vertical furrows, by hydration.
const SOIL_DRY_REGION := Rect2(8, 16, 8, 8)
const SOIL_WET_REGION := Rect2(24, 16, 8, 8)
## Plain grass fill on the plains sheet.
const GRASS_REGION := Rect2(24, 32, 8, 8)

var allotment: Allotment:
	set(value):
		if allotment != null:
			allotment.changed.disconnect(queue_redraw)
		allotment = value
		if allotment != null:
			allotment.changed.connect(queue_redraw)
			custom_minimum_size = Vector2(allotment.width + 2 * BORDER, allotment.height + 2 * BORDER) * TILE_SIZE
		queue_redraw()
var tool: Tool = Tool.PLANT
var selected_crop: CropDef

var _farm_sheet: Texture2D
var _crop_sheet: Texture2D
var _plains_sheet: Texture2D


func _ready() -> void:
	_farm_sheet = _try_load(FARM_TILESET)
	_crop_sheet = _try_load(CROP_SHEET)
	_plains_sheet = _try_load(PLAINS_TILESET)
	if _farm_sheet == null or _crop_sheet == null or _plains_sheet == null:
		print("AllotmentView: Minifantasy sheets missing, drawing placeholder shapes")


func has_sprites() -> bool:
	return _farm_sheet != null and _crop_sheet != null and _plains_sheet != null


func _gui_input(event: InputEvent) -> void:
	# Mouse clicks arrive as touches too (emulate_touch_from_mouse), so only touch is handled.
	if event is InputEventScreenTouch and event.pressed:
		var cell := Vector2i((event.position / TILE_SIZE).floor()) - Vector2i(BORDER, BORDER)
		if allotment != null and allotment.in_bounds(cell.x, cell.y):
			_apply_tool(cell.x, cell.y)
			accept_event()


func _apply_tool(x: int, y: int) -> void:
	match tool:
		Tool.PLANT:
			allotment.plant(x, y, selected_crop)
		Tool.WATER:
			allotment.water(x, y)
		Tool.HARVEST:
			allotment.harvest(x, y)


func _draw() -> void:
	if allotment == null:
		return
	_draw_grass()
	for y in allotment.height:
		for x in allotment.width:
			_draw_soil(x, y, allotment.tile_at(x, y))
	# Plants are drawn after all soil, top row first, since sprites overlap the tile above.
	for y in allotment.height:
		for x in allotment.width:
			_draw_plant(x, y, allotment.tile_at(x, y))


func _tile_rect(x: int, y: int) -> Rect2:
	return Rect2(Vector2(x + BORDER, y + BORDER) * TILE_SIZE, Vector2.ONE * TILE_SIZE)


func _draw_grass() -> void:
	var cols := allotment.width + 2 * BORDER
	var rows := allotment.height + 2 * BORDER
	if _plains_sheet == null:
		draw_rect(Rect2(Vector2.ZERO, Vector2(cols, rows) * TILE_SIZE), GRASS)
		return
	for y in rows:
		for x in cols:
			var rect := Rect2(Vector2(x, y) * TILE_SIZE, Vector2.ONE * TILE_SIZE)
			draw_texture_rect_region(_plains_sheet, rect, GRASS_REGION)


func _draw_soil(x: int, y: int, tile: PlotTile) -> void:
	var rect := _tile_rect(x, y)
	if _farm_sheet == null:
		draw_rect(rect, SOIL_WET if tile.watered else SOIL_DRY)
		draw_rect(rect, GRID_LINE, false, 2.0)
		return
	draw_texture_rect_region(_farm_sheet, rect, SOIL_WET_REGION if tile.watered else SOIL_DRY_REGION)


func _draw_plant(x: int, y: int, tile: PlotTile) -> void:
	if tile.state == PlotTile.State.EMPTY:
		return
	var rect := _tile_rect(x, y)
	if _crop_sheet == null or not tile.crop.has_sprite():
		var centre := rect.get_center()
		var radius := lerpf(8.0, TILE_SIZE * 0.38, tile.growth_fraction())
		draw_circle(centre, radius, tile.crop.colour)
		if tile.state == PlotTile.State.MATURE:
			draw_arc(centre, radius + 6.0, 0.0, TAU, 32, RIPE_RING, 3.0)
		return
	# Frames: 2 = seeds on the ground, 3-4 = growing, 5 = fully grown.
	var frame := 5 if tile.state == PlotTile.State.MATURE else mini(2 + tile.stage, 4)
	var sprite_rect := Rect2(rect.position - Vector2(0, TILE_SIZE), Vector2(TILE_SIZE, 2 * TILE_SIZE))
	draw_texture_rect_region(_crop_sheet, sprite_rect, tile.crop.frame_region(frame))
	if tile.state == PlotTile.State.MATURE:
		var icon_size := Vector2.ONE * TILE_SIZE * 0.5
		var icon_rect := Rect2(rect.end - icon_size, icon_size)
		draw_texture_rect_region(_crop_sheet, icon_rect, tile.crop.icon_region())


static func _try_load(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

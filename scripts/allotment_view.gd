class_name AllotmentView
extends Control
## Draws the allotment grid and turns taps into actions.
## Uses the Minifantasy Farm sheets when they are on disk (see Minifantasy) and
## falls back to coloured shapes otherwise, so CI and fresh checkouts still run.

enum Tool { PLANT, WATER, HARVEST }

## 8 px source pixels drawn at 8x: a 10x7 tile view (plot plus border) fits 1280x720.
const PIXEL_SCALE := 8
const TILE_SIZE := 8 * PIXEL_SCALE
## Ring of tiles around the plot that carries the fence.
const BORDER := 1

const SOIL_DRY := Color(0.45, 0.31, 0.2)
const SOIL_WET := Color(0.3, 0.2, 0.14)
const GRID_LINE := Color(0.2, 0.13, 0.08)
const FENCE_LINE := Color(0.55, 0.35, 0.15)
const RIPE_RING := Color(1.0, 0.9, 0.3)

## Farm tileset fence pieces, taken from the 5x5 enclosure mock-up.
const FENCE_TOP_LEFT := Rect2(400, 120, 8, 8)
const FENCE_TOP := Rect2(408, 120, 8, 8)
const FENCE_TOP_RIGHT := Rect2(432, 120, 8, 8)
const FENCE_LEFT := Rect2(400, 128, 8, 8)
const FENCE_RIGHT := Rect2(432, 128, 8, 8)
const FENCE_BOTTOM_LEFT := Rect2(400, 152, 8, 8)
const FENCE_BOTTOM := Rect2(408, 152, 8, 8)
const FENCE_BOTTOM_RIGHT := Rect2(432, 152, 8, 8)

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

## Short feedback animations: harvesting shows the farmer crouching over the tile,
## watering shows the Farm pack's bucket icon filling. Each entry is
## {kind: Tool, cell: Vector2i, start: float (seconds), duration: float}.
const HARVEST_DURATION := 0.7
const WATER_DURATION := 0.5
const WATER_FRAMES := 4
const WATER_ICON_SCALE := 4

var _farm_sheet: Texture2D
var _crop_sheet: Texture2D
var _harvest_sheet: Texture2D
var _action_sheet: Texture2D
var _effects: Array[Dictionary] = []


func _ready() -> void:
	_farm_sheet = Minifantasy.farm_tileset()
	_crop_sheet = Minifantasy.crop_sheet()
	_harvest_sheet = Minifantasy.harvest_sheet()
	_action_sheet = Minifantasy.action_sheet()
	set_process(false)
	if not has_sprites():
		print("AllotmentView: Minifantasy sheets missing, drawing placeholder shapes")


func _process(_delta: float) -> void:
	var now := _now()
	_effects = _effects.filter(func(effect: Dictionary) -> bool:
		return now - float(effect.start) < float(effect.duration))
	if _effects.is_empty():
		set_process(false)
	queue_redraw()


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _play_effect(kind: Tool, x: int, y: int) -> void:
	var sheet := _harvest_sheet if kind == Tool.HARVEST else _action_sheet
	if sheet == null:
		return
	var duration := HARVEST_DURATION if kind == Tool.HARVEST else WATER_DURATION
	_effects.append({"kind": kind, "cell": Vector2i(x, y), "start": _now(), "duration": duration})
	set_process(true)
	queue_redraw()


func has_sprites() -> bool:
	return _farm_sheet != null and _crop_sheet != null


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
			if allotment.water(x, y):
				_play_effect(Tool.WATER, x, y)
		Tool.HARVEST:
			if allotment.harvest(x, y) > 0:
				_play_effect(Tool.HARVEST, x, y)


func _draw() -> void:
	if allotment == null:
		return
	_draw_fence()
	for y in allotment.height:
		for x in allotment.width:
			_draw_soil(x, y, allotment.tile_at(x, y))
	# Plants are drawn after all soil, top row first, since sprites overlap the tile above.
	for y in allotment.height:
		for x in allotment.width:
			_draw_plant(x, y, allotment.tile_at(x, y))
	for effect in _effects:
		_draw_effect(effect)


func _draw_effect(effect: Dictionary) -> void:
	var cell: Vector2i = effect.cell
	var rect := _tile_rect(cell.x, cell.y)
	var progress := clampf((_now() - float(effect.start)) / float(effect.duration), 0.0, 0.999)
	if effect.kind == Tool.HARVEST:
		# The 32x32 cell is centred on the character, so centre it on the tile.
		var frame := int(progress * Minifantasy.HARVEST_FRAMES)
		var cell_size := Vector2.ONE * Minifantasy.HARVEST_CELL * PIXEL_SCALE
		var dest := Rect2(rect.get_center() - cell_size * 0.5, cell_size)
		draw_texture_rect_region(_harvest_sheet, dest, Minifantasy.harvest_frame_region(frame))
	else:
		var frame := int(progress * WATER_FRAMES)
		var icon_size := Vector2.ONE * Minifantasy.ACTION_FRAME * WATER_ICON_SCALE
		var dest := Rect2(rect.get_center() - icon_size * 0.5 - Vector2(0, TILE_SIZE * 0.5), icon_size)
		draw_texture_rect_region(_action_sheet, dest, Minifantasy.action_frame_region(Minifantasy.Action.WATER, frame))


func _tile_rect(x: int, y: int) -> Rect2:
	return Rect2(Vector2(x + BORDER, y + BORDER) * TILE_SIZE, Vector2.ONE * TILE_SIZE)


func _draw_fence() -> void:
	var right := allotment.width
	var bottom := allotment.height
	if _farm_sheet == null:
		var inset := TILE_SIZE * 0.5
		var outline := Rect2(Vector2.ONE * inset, size - Vector2.ONE * 2.0 * inset)
		draw_rect(outline, FENCE_LINE, false, 6.0)
		return
	_draw_piece(-1, -1, FENCE_TOP_LEFT)
	_draw_piece(right, -1, FENCE_TOP_RIGHT)
	_draw_piece(-1, bottom, FENCE_BOTTOM_LEFT)
	_draw_piece(right, bottom, FENCE_BOTTOM_RIGHT)
	for x in right:
		_draw_piece(x, -1, FENCE_TOP)
		_draw_piece(x, bottom, FENCE_BOTTOM)
	for y in bottom:
		_draw_piece(-1, y, FENCE_LEFT)
		_draw_piece(right, y, FENCE_RIGHT)


func _draw_piece(x: int, y: int, region: Rect2) -> void:
	draw_texture_rect_region(_farm_sheet, _tile_rect(x, y), region)


func _draw_soil(x: int, y: int, tile: PlotTile) -> void:
	var rect := _tile_rect(x, y)
	if _farm_sheet == null:
		draw_rect(rect, SOIL_WET if tile.watered else SOIL_DRY)
		draw_rect(rect, GRID_LINE, false, 2.0)
		return
	var region := Minifantasy.SOIL_WET_REGION if tile.watered else Minifantasy.SOIL_DRY_REGION
	draw_texture_rect_region(_farm_sheet, rect, region)


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

class_name AllotmentView
extends Control
## Draws the allotment grid with placeholder shapes and turns taps into actions.
## Replace _draw() with sprites once Minifantasy tiles are imported.

enum Tool { PLANT, WATER, HARVEST }

const TILE_SIZE := 96
const SOIL_DRY := Color(0.45, 0.31, 0.2)
const SOIL_WET := Color(0.3, 0.2, 0.14)
const GRID_LINE := Color(0.2, 0.13, 0.08)
const RIPE_RING := Color(1.0, 0.9, 0.3)

var allotment: Allotment:
	set(value):
		if allotment != null:
			allotment.changed.disconnect(queue_redraw)
		allotment = value
		if allotment != null:
			allotment.changed.connect(queue_redraw)
			custom_minimum_size = Vector2(allotment.width, allotment.height) * TILE_SIZE
		queue_redraw()
var tool: Tool = Tool.PLANT
var selected_crop: CropDef


func _gui_input(event: InputEvent) -> void:
	# Mouse clicks arrive as touches too (emulate_touch_from_mouse), so only touch is handled.
	if event is InputEventScreenTouch and event.pressed:
		var cell := Vector2i((event.position / TILE_SIZE).floor())
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
	for y in allotment.height:
		for x in allotment.width:
			_draw_tile(x, y, allotment.tile_at(x, y))


func _draw_tile(x: int, y: int, tile: PlotTile) -> void:
	var rect := Rect2(Vector2(x, y) * TILE_SIZE, Vector2.ONE * TILE_SIZE)
	draw_rect(rect, SOIL_WET if tile.watered else SOIL_DRY)
	draw_rect(rect, GRID_LINE, false, 2.0)
	if tile.state == PlotTile.State.EMPTY:
		return
	var centre := rect.get_center()
	var radius := lerpf(8.0, TILE_SIZE * 0.38, tile.growth_fraction())
	draw_circle(centre, radius, tile.crop.colour)
	if tile.state == PlotTile.State.MATURE:
		draw_arc(centre, radius + 6.0, 0.0, TAU, 32, RIPE_RING, 3.0)

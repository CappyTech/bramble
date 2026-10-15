extends Control
## Fills its rect with tiled Minifantasy grass, or a flat green when the pack is absent.

const PIXEL_SCALE := AllotmentView.PIXEL_SCALE
const TILE_SIZE := 8 * PIXEL_SCALE
const FALLBACK := Color(0.42, 0.6, 0.25)


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var sheet := Minifantasy.plains_tileset()
	if sheet == null:
		draw_rect(Rect2(Vector2.ZERO, size), FALLBACK)
		return
	var cols := ceili(size.x / TILE_SIZE)
	var rows := ceili(size.y / TILE_SIZE)
	for y in rows:
		for x in cols:
			var rect := Rect2(Vector2(x, y) * TILE_SIZE, Vector2.ONE * TILE_SIZE)
			draw_texture_rect_region(sheet, rect, Minifantasy.GRASS_REGION)

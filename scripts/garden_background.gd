extends Control
## Fills its rect with tiled Minifantasy grass and scatters props around the plot,
## each with its shadow layer when shadows are enabled. Flat green when the pack
## is absent.

const PIXEL_SCALE := AllotmentView.PIXEL_SCALE
const TILE_SIZE := 8 * PIXEL_SCALE
const FALLBACK := Color(0.42, 0.6, 0.25)

enum Sheet { PLAINS, FARM }

## Decorations in 1280x720 design pixels: [sheet, source region, top-left position].
## The plot view sits at x 320-960, y 123-571; the HUD is above and the toolbar below.
const PROPS: Array = [
	[Sheet.PLAINS, Rect2(144, 0, 32, 32), Vector2(1000, 56)],     # tree, top right
	[Sheet.PLAINS, Rect2(144, 32, 32, 32), Vector2(24, 372)],     # tree, bottom left
	[Sheet.PLAINS, Rect2(104, 16, 16, 16), Vector2(72, 144)],     # rock, top left
	[Sheet.PLAINS, Rect2(120, 8, 16, 24), Vector2(1136, 300)],    # standing stone, right
	[Sheet.FARM, Rect2(56, 8, 16, 24), Vector2(1000, 330)],       # hay pile, right
	[Sheet.FARM, Rect2(16, 48, 8, 8), Vector2(1020, 540)],        # hay bale
	[Sheet.FARM, Rect2(24, 48, 8, 8), Vector2(1084, 540)],        # hay bale
	[Sheet.FARM, Rect2(96, 48, 16, 16), Vector2(184, 240)],       # scarecrow, left
	[Sheet.FARM, Rect2(32, 48, 8, 8), Vector2(200, 560)],         # hay bale by the gate
	[Sheet.FARM, Rect2(136, 16, 8, 16), Vector2(292, 548)],       # water butt by the gate
	[Sheet.PLAINS, Rect2(72, 72, 8, 8), Vector2(1096, 240)],      # flowers
	[Sheet.PLAINS, Rect2(80, 72, 8, 8), Vector2(1180, 500)],
	[Sheet.PLAINS, Rect2(88, 72, 8, 8), Vector2(120, 300)],
	[Sheet.PLAINS, Rect2(96, 72, 8, 8), Vector2(260, 96)],
	[Sheet.PLAINS, Rect2(72, 48, 16, 16), Vector2(1180, 120)],    # grass tuft
	[Sheet.PLAINS, Rect2(72, 48, 16, 16), Vector2(96, 560)],
]

@export var draw_props := true


func _ready() -> void:
	resized.connect(queue_redraw)
	App.settings_changed.connect(queue_redraw)


func _draw() -> void:
	var grass := Minifantasy.plains_tileset()
	if grass == null:
		draw_rect(Rect2(Vector2.ZERO, size), FALLBACK)
		return
	var cols := ceili(size.x / TILE_SIZE)
	var rows := ceili(size.y / TILE_SIZE)
	for y in rows:
		for x in cols:
			var rect := Rect2(Vector2(x, y) * TILE_SIZE, Vector2.ONE * TILE_SIZE)
			draw_texture_rect_region(grass, rect, Minifantasy.GRASS_REGION)
	if draw_props:
		_draw_props()


func _draw_props() -> void:
	var sheets := {
		Sheet.PLAINS: [Minifantasy.plains_props(), Minifantasy.plains_props_shadow()],
		Sheet.FARM: [Minifantasy.farm_props(), Minifantasy.farm_props_shadow()],
	}
	# Shadows first so no prop's shadow lands on top of a neighbouring prop.
	if App.shadows:
		for prop in PROPS:
			var shadow: Texture2D = sheets[prop[0]][1]
			if shadow != null:
				draw_texture_rect_region(shadow, _prop_rect(prop), prop[1])
	for prop in PROPS:
		var sheet: Texture2D = sheets[prop[0]][0]
		if sheet != null:
			draw_texture_rect_region(sheet, _prop_rect(prop), prop[1])


func _prop_rect(prop: Array) -> Rect2:
	var region: Rect2 = prop[1]
	return Rect2(prop[2], region.size * PIXEL_SCALE)

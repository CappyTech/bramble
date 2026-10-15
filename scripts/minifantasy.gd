class_name Minifantasy
extends RefCounted
## Loads the Minifantasy sheets from assets/minifantasy (gitignored; see its README)
## and cuts icons out of them. Every accessor returns null when the pack is not on
## disk so callers can fall back to placeholders.

const DIR := "res://assets/minifantasy/"
const FARM_DIR := DIR + "farm/Minifantasy_Farm_v3.0/Minifantasy_Farm_Assets/"
const PLAINS_DIR := DIR + "forgotten_plains/Minifantasy_ForgottenPlains_v3.6_Commercial_Version/Minifantasy_ForgottenPlains_Assets/"

const FARM_TILESET := FARM_DIR + "Tileset/Minifantasy_FarmTileset.png"
const CROP_SHEET := FARM_DIR + "Crops/Minifantasy_FarmSeedsAndCrops.png"
const ACTION_SHEET := FARM_DIR + "Actions/Minifantasy_FarmActionInProgress(16x16).png"
const PLAINS_TILESET := PLAINS_DIR + "Tileset/Minifantasy_ForgottenPlainsTiles.png"
const CRAFTING_DIR := DIR + "crafting_1/Minifantasy_CraftingAndProfessions_v1.0/Minifantasy_CraftingAndProfessions_Assets/"
const HARVEST_SHEET := CRAFTING_DIR + "Gathering_Professions/Harvesting/_Characters/Minifantasy_CraftingAndProfessionsHarvestAnimation_human.png"

## Harvest animation sheet: 32x32 cells, six frames per row (column 0 standing),
## one row per facing direction. Row 0 faces the camera.
const HARVEST_CELL := 32
const HARVEST_FRAMES := 6
const HARVEST_ROW_FRONT := 0

## Farm tileset: single horizontal furrow rows; the three rows are hydration states
## (y 104 dry, 112 moist, 120 wet). The plain dirt tiles at x 48 are texture
## variants, not hydration, so they are not used.
const SOIL_DRY_REGION := Rect2(16, 104, 8, 8)
const SOIL_WET_REGION := Rect2(16, 120, 8, 8)
## Plains tileset: plain grass fill.
const GRASS_REGION := Rect2(24, 32, 8, 8)

## Action sheet: 16x16 frames, four per row. Rows by what they show.
enum Action { PLOUGH, HARVEST, SHEAR, PLANT, FEED, WATER, SLAUGHTER, MILK, FETCH_WATER }
const ACTION_FRAME := 16

static var _cache: Dictionary = {}


static func farm_tileset() -> Texture2D:
	return _texture(FARM_TILESET)


static func crop_sheet() -> Texture2D:
	return _texture(CROP_SHEET)


static func action_sheet() -> Texture2D:
	return _texture(ACTION_SHEET)


static func plains_tileset() -> Texture2D:
	return _texture(PLAINS_TILESET)


static func harvest_sheet() -> Texture2D:
	return _texture(HARVEST_SHEET)


static func harvest_frame_region(frame: int, row: int = HARVEST_ROW_FRONT) -> Rect2:
	return Rect2(frame * HARVEST_CELL, row * HARVEST_CELL, HARVEST_CELL, HARVEST_CELL)


static func action_frame_region(action: Action, frame: int) -> Rect2:
	return Rect2(frame * ACTION_FRAME, action * ACTION_FRAME, ACTION_FRAME, ACTION_FRAME)


static func available() -> bool:
	return farm_tileset() != null and crop_sheet() != null and plains_tileset() != null


## Last (completed) frame of an action icon, scaled up with nearest filtering.
static func action_icon(action: Action, scale: int) -> Texture2D:
	return icon(action_sheet(), action_frame_region(action, 3), scale)


static func crop_icon(def: CropDef, scale: int) -> Texture2D:
	if not def.has_sprite():
		return null
	return icon(crop_sheet(), def.icon_region(), scale)


## Cuts a region out of a sheet and upscales it so UI nodes show it at pixel size.
static func icon(sheet: Texture2D, region: Rect2, scale: int) -> Texture2D:
	if sheet == null:
		return null
	var key := "%s|%s|%d" % [sheet.resource_path, region, scale]
	if _cache.has(key):
		return _cache[key]
	var image := sheet.get_image().get_region(Rect2i(region))
	image.resize(image.get_width() * scale, image.get_height() * scale, Image.INTERPOLATE_NEAREST)
	var texture := ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture


static func _texture(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	# A miss is not cached: the editor may still be importing the sheet.
	if texture != null:
		_cache[path] = texture
	return texture

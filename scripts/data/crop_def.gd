class_name CropDef
extends Resource
## Static definition of a crop. Data only; growth behaviour lives in PlotTile.
## Soil, rotation, pests and frost are not simulated yet; the reserved fields
## below exist so those systems can be added without reshaping saved data.

@export var id: StringName
@export var display_name: String
## Days a watered plant spends in each growth stage. The plant is mature once
## it has passed through every stage.
@export var stage_days: PackedInt32Array = PackedInt32Array([2, 3, 3])
## Units produced by one harvest.
@export var yield_amount: int = 1
## Placeholder colour, used when the Minifantasy crop sheet is not on disk.
@export var colour: Color = Color.GREEN
## Position on the Minifantasy Farm crop sheet: column group (0-2) and row (0-4).
## (-1, -1) means no sprite.
@export var sheet_cell: Vector2i = Vector2i(-1, -1)

## Crop sheet layout (Minifantasy_FarmSeedsAndCrops.png): three 80 px column
## groups, five 16 px rows. Frames 0-5 sit 8 px apart from x = 8; the grown
## crop icon sits at x = 64. Frames: seed pack, one seed, seeds, growing 1-3.
const SHEET_GROUP_WIDTH := 80
const SHEET_ROW_HEIGHT := 16
const SHEET_FRAME_X := 8
const SHEET_ICON_X := 64
const FRAME_SIZE := Vector2(8, 16)
const ICON_SIZE := Vector2(8, 8)


func has_sprite() -> bool:
	return sheet_cell.x >= 0 and sheet_cell.y >= 0


## Region of the plant sprite for growth frame 0-5.
func frame_region(frame: int) -> Rect2:
	var origin := Vector2(
		sheet_cell.x * SHEET_GROUP_WIDTH + SHEET_FRAME_X + clampi(frame, 0, 5) * 8,
		sheet_cell.y * SHEET_ROW_HEIGHT)
	return Rect2(origin, FRAME_SIZE)


## Region of the harvested-crop icon.
func icon_region() -> Rect2:
	var origin := Vector2(
		sheet_cell.x * SHEET_GROUP_WIDTH + SHEET_ICON_X,
		sheet_cell.y * SHEET_ROW_HEIGHT + 4)
	return Rect2(origin, ICON_SIZE)

## Reserved: crop family used for rotation rules. Unused by current logic.
@export var rotation_group: StringName = &""
## Reserved: whether the plant survives a frost. Unused by current logic.
@export var frost_hardy: bool = false


func stage_count() -> int:
	return stage_days.size()


func total_days() -> int:
	var total := 0
	for days in stage_days:
		total += days
	return total

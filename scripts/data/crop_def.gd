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
## Placeholder colour until Minifantasy sprites are imported.
@export var colour: Color = Color.GREEN

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

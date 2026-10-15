class_name PlotTile
extends RefCounted
## One square of the allotment. Holds what is planted and how far along it is.
## Growth only happens on a day the tile was watered.

enum State { EMPTY, GROWING, MATURE }

var state: State = State.EMPTY
var crop: CropDef = null
## Index of the current growth stage, 0-based.
var stage: int = 0
var days_in_stage: int = 0
var watered: bool = false
## Reserved for soil quality, pests and rotation history. Unused for now.
var soil: Dictionary = {}


func plant(def: CropDef) -> bool:
	if state != State.EMPTY or def == null:
		return false
	crop = def
	state = State.GROWING
	stage = 0
	days_in_stage = 0
	return true


func water() -> bool:
	if watered:
		return false
	watered = true
	return true


## Returns the number of units harvested, or 0 if nothing was ready.
func harvest() -> int:
	if state != State.MATURE:
		return 0
	var amount := crop.yield_amount
	crop = null
	state = State.EMPTY
	stage = 0
	days_in_stage = 0
	return amount


## Called once when the player sleeps. Advances growth if watered, then dries out.
func end_day() -> void:
	if state == State.GROWING and watered:
		days_in_stage += 1
		if days_in_stage >= crop.stage_days[stage]:
			stage += 1
			days_in_stage = 0
			if stage >= crop.stage_count():
				stage = crop.stage_count()
				state = State.MATURE
	watered = false


## 0.0 just planted, 1.0 mature. For drawing placeholder growth.
func growth_fraction() -> float:
	if state == State.EMPTY:
		return 0.0
	if state == State.MATURE:
		return 1.0
	var elapsed := days_in_stage
	for i in stage:
		elapsed += crop.stage_days[i]
	return float(elapsed) / float(crop.total_days())

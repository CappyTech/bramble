extends Control
## Entry scene: wires the HUD and toolbar to one Allotment.

const GRID_WIDTH := 8
const GRID_HEIGHT := 5
## Upscale for 8 px and 16 px sheet icons shown in buttons.
const ICON_SCALE := 3

var allotment := Allotment.new(GRID_WIDTH, GRID_HEIGHT)
var crops: Array[CropDef] = CropLibrary.all()

@onready var view: AllotmentView = %AllotmentView
@onready var day_label: Label = %DayLabel
@onready var harvest_label: Label = %HarvestLabel
@onready var plant_button: Button = %PlantButton
@onready var water_button: Button = %WaterButton
@onready var harvest_button: Button = %HarvestButton
@onready var crop_select: OptionButton = %CropSelect
@onready var sleep_button: Button = %SleepButton
@onready var night: ColorRect = %Night

const NIGHT_FADE_SECONDS := 0.4
const NIGHT_HOLD_SECONDS := 0.3
var _sleeping := false


func _ready() -> void:
	print("Bramble %s" % ProjectSettings.get_setting("application/config/version", "dev"))
	view.allotment = allotment
	for def in crops:
		var icon := Minifantasy.crop_icon(def, ICON_SCALE)
		if icon != null:
			crop_select.add_icon_item(icon, def.display_name)
		else:
			crop_select.add_item(def.display_name)
	crop_select.select(0)
	plant_button.icon = Minifantasy.action_icon(Minifantasy.Action.PLANT, ICON_SCALE)
	water_button.icon = Minifantasy.action_icon(Minifantasy.Action.WATER, ICON_SCALE)
	harvest_button.icon = Minifantasy.action_icon(Minifantasy.Action.HARVEST, ICON_SCALE)
	view.selected_crop = crops[0]
	crop_select.item_selected.connect(func(index: int) -> void: view.selected_crop = crops[index])
	plant_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.PLANT)
	water_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.WATER)
	harvest_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.HARVEST)
	sleep_button.pressed.connect(_sleep)
	allotment.changed.connect(_refresh_hud)
	_refresh_hud()


## Fade to night, advance the day, fade back in.
func _sleep() -> void:
	if _sleeping:
		return
	_sleeping = true
	sleep_button.disabled = true
	var tween := create_tween()
	tween.tween_property(night, "color:a", 1.0, NIGHT_FADE_SECONDS)
	await tween.finished
	allotment.sleep()
	await get_tree().create_timer(NIGHT_HOLD_SECONDS, false).timeout
	tween = create_tween()
	tween.tween_property(night, "color:a", 0.0, NIGHT_FADE_SECONDS)
	await tween.finished
	sleep_button.disabled = false
	_sleeping = false


func _refresh_hud() -> void:
	day_label.text = "Day %d" % allotment.day
	var parts := PackedStringArray()
	for def in crops:
		var amount := int(allotment.harvested.get(def.id, 0))
		if amount > 0:
			parts.append("%s %d" % [def.display_name, amount])
	harvest_label.text = "Harvested: " + (", ".join(parts) if parts.size() > 0 else "nothing yet")

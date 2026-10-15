extends Control
## Entry scene: wires the HUD and toolbar to one Allotment.

const GRID_WIDTH := 8
const GRID_HEIGHT := 5

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


func _ready() -> void:
	print("Bramble %s" % ProjectSettings.get_setting("application/config/version", "dev"))
	view.allotment = allotment
	for def in crops:
		crop_select.add_item(def.display_name)
	crop_select.select(0)
	view.selected_crop = crops[0]
	crop_select.item_selected.connect(func(index: int) -> void: view.selected_crop = crops[index])
	plant_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.PLANT)
	water_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.WATER)
	harvest_button.pressed.connect(func() -> void: view.tool = AllotmentView.Tool.HARVEST)
	sleep_button.pressed.connect(allotment.sleep)
	allotment.changed.connect(_refresh_hud)
	_refresh_hud()


func _refresh_hud() -> void:
	day_label.text = "Day %d" % allotment.day
	var parts := PackedStringArray()
	for def in crops:
		var amount := int(allotment.harvested.get(def.id, 0))
		if amount > 0:
			parts.append("%s %d" % [def.display_name, amount])
	harvest_label.text = "Harvested: " + (", ".join(parts) if parts.size() > 0 else "nothing yet")

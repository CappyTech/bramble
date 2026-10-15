class_name CropLibrary
extends RefCounted
## Built-in placeholder crops. Will move to .tres resources once art is imported.


static func all() -> Array[CropDef]:
	return [
		_make(&"radish", "Radish", [1, 1, 1], 3, Color(0.85, 0.2, 0.3), &"brassica"),
		_make(&"lettuce", "Lettuce", [2, 2, 2], 1, Color(0.45, 0.8, 0.3), &"leaf"),
		_make(&"potato", "Potato", [3, 3, 4], 4, Color(0.8, 0.7, 0.4), &"root"),
	]


static func find(id: StringName) -> CropDef:
	for def in all():
		if def.id == id:
			return def
	return null


static func _make(id: StringName, display_name: String, stage_days: Array,
		yield_amount: int, colour: Color, rotation_group: StringName) -> CropDef:
	var def := CropDef.new()
	def.id = id
	def.display_name = display_name
	def.stage_days = PackedInt32Array(stage_days)
	def.yield_amount = yield_amount
	def.colour = colour
	def.rotation_group = rotation_group
	return def

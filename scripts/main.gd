extends Node2D
## Entry scene. Placeholder until the allotment scene exists.


func _ready() -> void:
	print("Bramble %s" % ProjectSettings.get_setting("application/config/version", "dev"))

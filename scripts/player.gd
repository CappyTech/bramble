class_name Player
extends Node2D
## The player's avatar on the plot. Walks to a point, faces the way it moves,
## and plays a working animation when asked. Draws a plain disc when the
## Minifantasy character sheets are absent.

signal arrived

## Pixels per second: three tiles.
const SPEED := 3.0 * AllotmentView.TILE_SIZE
const ARRIVE_DISTANCE := 2.0
const FALLBACK_COLOUR := Color(0.95, 0.8, 0.6)
const WATER_ACT_SECONDS := 0.5

var facing: Minifantasy.Facing = Minifantasy.Facing.RIGHT
var _target: Vector2
var _walking := false
var _sprite: AnimatedSprite2D
var _shadow: AnimatedSprite2D


func _ready() -> void:
	var idle := Minifantasy.human_idle()
	var walk := Minifantasy.human_walk()
	var harvest := Minifantasy.harvest_sheet()
	if idle == null or walk == null or harvest == null:
		print("Player: character sheets missing, drawing a placeholder disc")
		return
	# The shadow sheets share the character sheets' layout, so the same frame
	# names drive both sprites in step.
	var shadow_idle := Minifantasy.human_shadow_idle()
	var shadow_walk := Minifantasy.human_shadow_walk()
	var shadow_harvest := Minifantasy.harvest_shadow_sheet()
	if shadow_idle != null and shadow_walk != null and shadow_harvest != null:
		_shadow = _make_sprite(_build_frames(shadow_idle, shadow_walk, shadow_harvest))
		_shadow.visible = App.shadows
		App.settings_changed.connect(func() -> void: _shadow.visible = App.shadows)
	_sprite = _make_sprite(_build_frames(idle, walk, harvest))
	_play_idle()


func _build_frames(idle: Texture2D, walk: Texture2D, harvest: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in 4:
		Minifantasy.add_row_animation(frames, "idle_%d" % row, idle, row, Minifantasy.IDLE_FRAMES, Minifantasy.ACTOR_FPS, true)
		Minifantasy.add_row_animation(frames, "walk_%d" % row, walk, row, Minifantasy.WALK_FRAMES, Minifantasy.ACTOR_FPS, true)
	Minifantasy.add_row_animation(frames, &"act", harvest, Minifantasy.HARVEST_ROW_FRONT, Minifantasy.HARVEST_FRAMES, Minifantasy.HARVEST_FPS, false)
	return frames


func _make_sprite(frames: SpriteFrames) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.scale = Vector2.ONE * AllotmentView.PIXEL_SCALE
	add_child(sprite)
	return sprite


func _draw() -> void:
	if _sprite == null:
		draw_circle(Vector2.ZERO, AllotmentView.TILE_SIZE * 0.3, FALLBACK_COLOUR)


func _process(delta: float) -> void:
	if not _walking:
		return
	var offset := _target - position
	var step := SPEED * delta
	if offset.length() <= maxf(step, ARRIVE_DISTANCE):
		position = _target
		_walking = false
		_play_idle()
		arrived.emit()
		return
	_face(offset)
	position += offset.normalized() * step
	_play(&"walk_%d" % facing)


## Walks to a point and returns once there. A later call replaces the target,
## and every pending await resumes on that later arrival.
func walk_to(point: Vector2) -> void:
	_target = point
	if (point - position).length() <= ARRIVE_DISTANCE:
		position = point
		_walking = false
		return
	_walking = true
	await arrived


## Plays the working pose for a tool and returns when it finishes.
func perform(tool: AllotmentView.Tool) -> void:
	if _sprite == null or tool == AllotmentView.Tool.WATER:
		# process_always false: the pose waits with the tree when the game pauses.
		await get_tree().create_timer(WATER_ACT_SECONDS, false).timeout
	else:
		_sprite.play(&"act")
		if _shadow != null:
			_shadow.play(&"act")
		await _sprite.animation_finished
	_play_idle()


func _face(direction: Vector2) -> void:
	var up := direction.y < -0.3 * absf(direction.x)
	var right := direction.x > 0.0 if not is_zero_approx(direction.x) else facing in [Minifantasy.Facing.RIGHT, Minifantasy.Facing.UP_RIGHT]
	if up:
		facing = Minifantasy.Facing.UP_RIGHT if right else Minifantasy.Facing.UP_LEFT
	else:
		facing = Minifantasy.Facing.RIGHT if right else Minifantasy.Facing.LEFT


func _play_idle() -> void:
	_play(&"idle_%d" % facing)


func _play(anim: StringName) -> void:
	if _sprite != null and _sprite.animation != anim:
		_sprite.play(anim)
		if _shadow != null:
			_shadow.play(anim)

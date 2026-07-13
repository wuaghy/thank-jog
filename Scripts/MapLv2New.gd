extends Node2D

const _LEVEL2_BGM := "res://Assets/audio/level2_bgm.mp3"
const _LEVEL2_BGM_DB := -16.0
const _LEVEL2_BOSS_BGM := "res://Assets/audio/level2_boss_bgm.mp3"
const _LEVEL2_BOSS_BGM_DB := -14.0

const _MAP_TEXTURE_SIZE := Vector2(1024, 559)
const _MAP_SCALE := 2.0
const _WATER_COLLISION_LAYER := 1

var _bgm_player: AudioStreamPlayer
var _boss_bgm_player: AudioStreamPlayer
var _water_polygons: Array[PackedVector2Array] = []
var _spawn_rects: Array[Rect2] = []


func _ready() -> void:
	_setup_map_meta()
	_setup_level2_bgm()
	if not Global.level2_minions_cleared.is_connected(_on_level2_minions_cleared_bgm):
		Global.level2_minions_cleared.connect(_on_level2_minions_cleared_bgm)


func _setup_level2_bgm() -> void:
	if not ResourceLoader.exists(_LEVEL2_BGM):
		return
	var stream: AudioStream = load(_LEVEL2_BGM) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = &"Level2Bgm"
	_bgm_player.stream = stream
	_bgm_player.volume_db = _LEVEL2_BGM_DB
	add_child(_bgm_player)
	_bgm_player.play()


func _on_level2_minions_cleared_bgm() -> void:
	_switch_to_boss_bgm()


func _switch_to_boss_bgm() -> void:
	if _boss_bgm_player != null:
		return
	if _bgm_player != null:
		_bgm_player.stop()
		_bgm_player.queue_free()
		_bgm_player = null
	if not ResourceLoader.exists(_LEVEL2_BOSS_BGM):
		return
	var stream: AudioStream = load(_LEVEL2_BOSS_BGM) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_boss_bgm_player = AudioStreamPlayer.new()
	_boss_bgm_player.name = &"Level2BossBgm"
	_boss_bgm_player.stream = stream
	_boss_bgm_player.volume_db = _LEVEL2_BOSS_BGM_DB
	add_child(_boss_bgm_player)
	_boss_bgm_player.play()


func _setup_map_meta() -> void:
	var map_size := _MAP_TEXTURE_SIZE * _MAP_SCALE
	set_meta("level2_map_bounds", Rect2(global_position, map_size))
	set_meta("level2_ui_exclusion", Rect2(Vector2(720, 500), Vector2(320, 220)))
	_build_play_areas()
	_build_water_collision()


func level2_is_spawn_position_valid(world_pos: Vector2) -> bool:
	if not _is_inside_any_spawn_rect(world_pos):
		return false
	return not _is_point_in_water(world_pos)


func _build_play_areas() -> void:
	_spawn_rects = [
		_scaled_rect(Rect2(350, 255, 170, 105)),
		_scaled_rect(Rect2(210, 270, 160, 85)),
		_scaled_rect(Rect2(250, 360, 270, 110)),
		_scaled_rect(Rect2(520, 230, 185, 110)),
		_scaled_rect(Rect2(690, 205, 130, 85)),
		_scaled_rect(Rect2(690, 395, 300, 95)),
		_scaled_rect(Rect2(40, 360, 210, 90)),
		_scaled_rect(Rect2(365, 470, 170, 70)),
	]


func _build_water_collision() -> void:
	_water_polygons = [
		_scaled_poly([Vector2(0, 143), Vector2(126, 145), Vector2(191, 130), Vector2(235, 143), Vector2(167, 177), Vector2(0, 178)]),
		_scaled_poly([Vector2(230, 129), Vector2(360, 113), Vector2(463, 116), Vector2(559, 113), Vector2(603, 137), Vector2(548, 164), Vector2(421, 154), Vector2(304, 160), Vector2(235, 154)]),
		_scaled_poly([Vector2(690, 110), Vector2(777, 106), Vector2(872, 123), Vector2(940, 115), Vector2(1024, 128), Vector2(1024, 183), Vector2(926, 196), Vector2(819, 184), Vector2(728, 171), Vector2(654, 160)]),
		_scaled_poly([Vector2(846, 32), Vector2(874, 45), Vector2(862, 114), Vector2(831, 120), Vector2(817, 96), Vector2(834, 70)]),
		_scaled_poly([Vector2(602, 280), Vector2(858, 281), Vector2(928, 301), Vector2(933, 368), Vector2(839, 396), Vector2(642, 373), Vector2(571, 345)]),
		_scaled_poly([Vector2(790, 548), Vector2(930, 525), Vector2(1024, 526), Vector2(1024, 559), Vector2(775, 559)]),
		_scaled_poly([Vector2(207, 37), Vector2(374, 32), Vector2(374, 103), Vector2(197, 110), Vector2(187, 70)]),
	]

	var old := get_node_or_null("WaterCollision")
	if old != null:
		old.queue_free()

	var body := StaticBody2D.new()
	body.name = &"WaterCollision"
	body.collision_layer = _WATER_COLLISION_LAYER
	body.collision_mask = 0
	add_child(body)

	for polygon in _water_polygons:
		var shape := CollisionPolygon2D.new()
		shape.polygon = polygon
		body.add_child(shape)


func _scaled_rect(r: Rect2) -> Rect2:
	return Rect2(r.position * _MAP_SCALE, r.size * _MAP_SCALE)


func _scaled_poly(points: Array[Vector2]) -> PackedVector2Array:
	var scaled := PackedVector2Array()
	for p in points:
		scaled.append(p * _MAP_SCALE)
	return scaled


func _is_inside_any_spawn_rect(world_pos: Vector2) -> bool:
	for r in _spawn_rects:
		if r.has_point(world_pos):
			return true
	return false


func _is_point_in_water(world_pos: Vector2) -> bool:
	for polygon in _water_polygons:
		if Geometry2D.is_point_in_polygon(world_pos, polygon):
			return true
	return false

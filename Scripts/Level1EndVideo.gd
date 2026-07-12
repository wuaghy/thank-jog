extends Control

const NEXT_SCENE_PATH := "res://Scenes/Level2InstructionOverlay.tscn"

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

var _transitioning: bool = false
var _videos: Array[String] = [
	"res://Assets/video/giong_an_com_va_lon_len.ogv",
	"res://Assets/video/giong_len_do.ogv"
]
var _current_video_idx: int = 0


func _ready() -> void:
	video_player.finished.connect(_on_video_finished)
	_current_video_idx = 0
	_play_current_video()


func _play_current_video() -> void:
	if _current_video_idx >= _videos.size():
		_go_to_next()
		return

	var stream := VideoStreamTheora.new()
	stream.file = _videos[_current_video_idx]
	video_player.stream = stream
	video_player.play()


func _on_video_finished() -> void:
	_current_video_idx += 1
	_play_current_video()


func _go_to_next() -> void:
	if _transitioning:
		return
	_transitioning = true
	video_player.stop()
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			var tree := get_tree()
			if tree != null:
				tree.root.set_input_as_handled()
			_go_to_next()


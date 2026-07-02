extends Control

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_hover: AudioStreamPlayer = $SfxHover
@onready var sfx_click: AudioStreamPlayer = $SfxClick

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var settings_button: Button = $MenuContainer/SettingsButton
@onready var quit_button: Button = $MenuContainer/QuitButton

@onready var settings_panel: ColorRect = $SettingsPanel
@onready var master_slider: HSlider = $SettingsPanel/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $SettingsPanel/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/VBoxContainer/SfxSlider
@onready var close_button: Button = $SettingsPanel/VBoxContainer/CloseButton

var _master_bus_idx: int
var _music_bus_idx: int
var _sfx_bus_idx: int

func _ready() -> void:
	# Bắt đầu phát nhạc nền
	var stream := music_player.stream
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	music_player.play()

	# Lấy index của các Audio Bus
	_master_bus_idx = AudioServer.get_bus_index("Master")
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")

	# Khởi tạo giá trị slider theo bus hiện tại
	master_slider.value = AudioServer.get_bus_volume_db(_master_bus_idx)
	if _music_bus_idx >= 0:
		music_slider.value = AudioServer.get_bus_volume_db(_music_bus_idx)
	if _sfx_bus_idx >= 0:
		sfx_slider.value = AudioServer.get_bus_volume_db(_sfx_bus_idx)

	# Nối tín hiệu các nút trong Menu chính
	_connect_button(play_button, _on_play_button_pressed)
	_connect_button(settings_button, _on_settings_pressed)
	_connect_button(quit_button, _on_quit_pressed)

	# Nối tín hiệu nút đóng và các slider trong cài đặt
	_connect_button(close_button, _on_close_settings_pressed)
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _connect_button(btn: Button, press_func: Callable) -> void:
	btn.pressed.connect(func() -> void:
		_play_sfx_click()
		press_func.call()
	)
	btn.mouse_entered.connect(_play_sfx_hover)

func _play_sfx_hover() -> void:
	sfx_hover.play()

func _play_sfx_click() -> void:
	sfx_click.play()

func _on_play_button_pressed() -> void:
	# Có thể delay một chút để nghe thấy tiếng click
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/Intro.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _on_close_settings_pressed() -> void:
	settings_panel.visible = false

func _on_master_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_master_bus_idx, value)
	# Mute if slider is at minimum
	AudioServer.set_bus_mute(_master_bus_idx, value == master_slider.min_value)

func _on_music_volume_changed(value: float) -> void:
	if _music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(_music_bus_idx, value)
		AudioServer.set_bus_mute(_music_bus_idx, value == music_slider.min_value)

func _on_sfx_volume_changed(value: float) -> void:
	if _sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(_sfx_bus_idx, value)
		AudioServer.set_bus_mute(_sfx_bus_idx, value == sfx_slider.min_value)

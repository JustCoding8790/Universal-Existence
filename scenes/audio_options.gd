extends VBoxContainer
@onready var master_slider: HSlider = $MasterVBox/MasterSlider
@onready var music_slider: HSlider = $MusicVBox/MusicSlider
@onready var sound_slider: HSlider = $SoundVBox/SoundSlider
@onready var voice_slider: HSlider = $VoiceVBox/VoiceSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(3))

func _on_master_slider_value_changed(value: float) -> void:
	release_focus()
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))

func _on_music_slider_value_changed(value: float) -> void:
	release_focus()
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sound_slider_value_changed(value: float) -> void:
	release_focus()
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_voice_slider_value_changed(value: float) -> void:
	release_focus()
	AudioServer.set_bus_volume_db(3, linear_to_db(value))

extends Panel
@onready var controller_settings: Panel = $"."
@onready var controller_settings_player: AnimationPlayer = $ControllerSettingsPlayer

@onready var sensitivity_slider: HSlider = $ControllerContainer/ControlVBox/SensitivityVBox/SensitivitySlider
@onready var deadzone_slider: HSlider = $ControllerContainer/ControlVBox/DeadzoneVBox/DeadzoneSlider
# @onready var vibration_slider: HSlider = $ControllerContainer/ControlVBox/VibrationVBox/VibrationSlider

@onready var back_button: Button = $Back
@onready var settings_exit: Button = $"../Settings/Exit"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set default slider values
	sensitivity_slider.value = 0.5
	deadzone_slider.value = 0.1
	# vibration_slider.value = 0.5

func open() -> void:
	settings_exit.disabled = true
	controller_settings.visible = true
	controller_settings_player.play("open")
	await controller_settings_player.animation_finished
	back_button.disabled = false

func _on_back_pressed() -> void:
	back_button.disabled = true
	controller_settings_player.play("close")
	await controller_settings_player.animation_finished
	controller_settings.visible = false
	settings_exit.disabled = false

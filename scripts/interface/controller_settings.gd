extends Panel
@onready var controller_settings: Panel = $"."
@onready var controller_settings_player: AnimationPlayer = $ControllerSettingsPlayer

@onready var sensitivity_slider: HSlider = $ControllerContainer/ControlVBox/SensitivityVBox/SensitivitySlider
@onready var deadzone_slider: HSlider = $ControllerContainer/ControlVBox/DeadzoneVBox/DeadzoneSlider
# @onready var vibration_slider: HSlider = $ControllerContainer/ControlVBox/VibrationVBox/VibrationSlider

@onready var back_button: Button = $Back
@onready var settings_exit: Button = $"../Settings/Exit"
@onready var features_button: Button = $"../Settings/RightMarginContainer/VBoxContainer/GameplayVBox/Features"

# --------------------
# CONTROLLER SETTINGS
# --------------------
func _on_sensitivity_slider_value_changed(_value: float) -> void:
	# Global.sensitivity_multi = value
	pass

func _on_deadzone_slider_value_changed(value: float) -> void:
	InputMap.action_set_deadzone("left", value)
	InputMap.action_set_deadzone("right", value)

# --------------------
# OPEN/CLOSE
# --------------------
func settings_open() -> void:
	features_button.disabled = true
	settings_exit.disabled = true
	controller_settings.visible = true
	controller_settings_player.play("open")
	await controller_settings_player.animation_finished
	back_button.disabled = false

func _on_settings_back_pressed() -> void:
	back_button.disabled = true
	controller_settings_player.play("close")
	await controller_settings_player.animation_finished
	controller_settings.visible = false
	settings_exit.disabled = false
	features_button.disabled = false

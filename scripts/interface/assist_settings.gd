extends Panel
@onready var assist_settings: Panel = $"."
@onready var game_speed_slider: HSlider = $ControllerContainer/VBoxContainer/GameSpeedVBox/GameSpeedSlider
@onready var speedrun_button: Button = $ControllerContainer/VBoxContainer/SpeedrunningVBox/Speedrun
@onready var training_button: Button = $ControllerContainer/VBoxContainer/TraiingVBox/Training
@onready var back_button: Button = $Back
@onready var settings_exit: Button = $"../Settings/Exit"
@onready var assist_settings_player: AnimationPlayer = $AssistSettingsPlayer
@onready var controller_button: Button = $"../Settings/RightMarginContainer/VBoxContainer/GameplayVBox/Controller"

# --------------------
# ASSIST FEATURES
# --------------------

func _on_game_speed_slider_value_changed(value: float) -> void:
	Engine.time_scale = value

func _on_speedrun_pressed() -> void:
	if Global.speedrun_timer_on:
		speedrun_button.text = "Speedrun Timers - OFF"
	else:
		speedrun_button.text = "Speedrun Timers - ON"
	# speedrun_panel.visible = Global.speedrun_timer_on
	Global.speedrun_timer_on = not Global.speedrun_timer_on

func _on_training_pressed() -> void:
	if Global.training:
		training_button.text = "Training Mode - OFF"
	else:
		training_button.text = "Training Mode - ON"
	Global.training = not Global.training

# --------------------
# OPEN/CLOSE
# --------------------

func assist_open() -> void:
	controller_button.disabled = true
	settings_exit.disabled = true
	assist_settings.visible = true
	if Global.speedrun_timer_on:
		speedrun_button.text = "Speedrun Timers - ON"
	else:
		speedrun_button.text = "Speedrun Timers - OFF"
	if Global.training:
		training_button.text = "Training Mode - ON"
	else:
		training_button.text = "Training Mode - OFF"
	assist_settings_player.play("open")
	await assist_settings_player.animation_finished
	back_button.disabled = false

func _on_assist_back_pressed() -> void:
	back_button.disabled = true
	assist_settings_player.play("close")
	await assist_settings_player.animation_finished
	assist_settings.visible = false
	settings_exit.disabled = false
	controller_button.disabled = false

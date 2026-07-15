extends Control
@onready var pause: CanvasLayer = $PauseLayer
@onready var main_player: AnimationPlayer = $PauseLayer/MainPlayer
@onready var difficulty_player: AnimationPlayer = $PauseLayer/DifficultyPlayer
@onready var difficulty_selection: Panel = $PauseLayer/DifficultySelection
@onready var difficulty: Button = $PauseLayer/PauseMain/MarginContainer/VBoxContainer/Difficulty
@onready var fade: ColorRect = $PauseLayer/Fade

var paused = false
var diff_menu = false
var pause_safe = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu()

func _on_resume_pressed() -> void:
	if paused:
		pause.hide()
		get_tree().paused = false
		paused = false

func _on_difficulty_pressed() -> void:
	difficulty.disabled = true
	if diff_menu:
		main_player.play("move_left")
		difficulty_player.play("difficulties_hide")
		difficulty_selection.hide()
	else:
		difficulty_selection.show()
		main_player.play("move_left")
		difficulty_player.play("difficulties_reveal")
	diff_menu = !diff_menu
	difficulty.disabled = false

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	fade.show()
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished
	get_tree().quit()

func pause_menu() -> void:
	pause_safe = false
	if paused:
		pause.hide()
		get_tree().paused = false
	else:
		pause.show()
		main_player.play("open")
		get_tree().paused = true
	paused = not paused
	pause_safe = true

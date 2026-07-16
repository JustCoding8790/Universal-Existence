extends Control
@onready var pause: CanvasLayer = $PauseLayer
@onready var pause_main: Panel = $PauseLayer/PauseMain
@onready var fade: ColorRect = $PauseLayer/Fade

@onready var difficulty: Button = $PauseLayer/PauseMain/MarginContainer/VBoxContainer/Difficulty

@onready var difficulty_selection: Panel = $PauseLayer/DifficultySelection
@onready var difficulty_description: Panel = $PauseLayer/DifficultyDescription
@onready var difficulty_title: Label = $PauseLayer/DifficultyDescription/DifficultyTitle
@onready var difficulty_text: Label = $PauseLayer/DifficultyDescription/DifficultyText

@onready var main_player: AnimationPlayer = $PauseLayer/MainPlayer
@onready var difficulty_player: AnimationPlayer = $PauseLayer/DifficultyPlayer
@onready var description_player: AnimationPlayer = $PauseLayer/DescriptionPlayer

var paused = false
var diff_menu = false
var pause_safe = true
var previous_difficulty = 3

signal difficulty_changed

func _ready() -> void:
	# Positioning fallback
	difficulty_selection.position = Vector2(427.25, 80.23)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and pause_safe:
		pause_menu()

func _on_resume_pressed() -> void:
	if paused:
		pause.hide()
		get_tree().paused = false
		difficulty_selection.hide()
		difficulty_description.hide()
		paused = false
		diff_menu = false
		if Global.difficulty != previous_difficulty:
			difficulty_changed.emit(Global.world, Global.level, false, true)

func _on_difficulty_pressed() -> void:
	difficulty.disabled = true
	if diff_menu:
		main_player.play("diff_right")
		difficulty_player.play("difficulties_hide")
		description_player.play("description_hide")
		await main_player.animation_finished
		difficulty_selection.hide()
		difficulty_description.hide()
		main_player.play("move_down")
		await main_player.animation_finished
	else:
		main_player.play("move_up")
		await main_player.animation_finished
		difficulty_selection.show()
		difficulty_description.show()
		set_difficulty_description()
		main_player.play("diff_left")
		difficulty_player.play("difficulties_reveal")
		description_player.play("description_reveal")
		await main_player.animation_finished
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
		difficulty_selection.hide()
		difficulty_description.hide()
		diff_menu = false
		if Global.difficulty != previous_difficulty:
			difficulty_changed.emit(Global.world, Global.level, false, true)
	else:
		pause.show()
		get_tree().paused = true
		main_player.play("open")
		await main_player.animation_finished
		previous_difficulty = Global.difficulty
	paused = not paused
	pause_safe = true

func set_difficulty_description() -> void:
	var new_style_box = difficulty_description.get_theme_stylebox("panel").duplicate()
	if Global.difficulty == 3:
		difficulty_title.text = "Extreme"
		difficulty_text.text = "For the most skilled jumpers of the universe.\nNot for the faint of heart."
		new_style_box.set("bg_color", Color("8f29b6"))
	elif Global.difficulty == 2:
		difficulty_title.text = "Ultra Hard"
		difficulty_text.text = "For all intermediate jumpers looking for a challenge.\nServes as a fairly difficult journey."
		new_style_box.set("bg_color", Color("d93444"))
	elif Global.difficulty == 1:
		difficulty_title.text = "Extra Hard"
		difficulty_text.text = "For rusty jumpers seeking to improve their skills.\nA casual, balanced experience."
		new_style_box.set("bg_color", Color("ec7137"))
	elif Global.difficulty == 0:
		difficulty_title.text = "Hard"
		difficulty_text.text = "For those who have no experience and just want to have fun.\nNo shame if this applies to you."
		new_style_box.set("bg_color", Color("a88e2b"))
	else:
		difficulty_title.text = "Cheater-Proof"
		difficulty_text.text = "For all jumpers that attempt to exploit the game.\nOr maybe it was just a bug?"
		new_style_box.set("bg_color", Color("000000"))
		Global.difficulty = 3
	difficulty_description.add_theme_stylebox_override("panel", new_style_box)

func _on_extreme_selected() -> void:
	Global.difficulty = 3
	set_difficulty_description()

func _on_ultra_hard_selected() -> void:
	Global.difficulty = 2
	set_difficulty_description()

func _on_extra_hard_selected() -> void:
	Global.difficulty = 1
	set_difficulty_description()

func _on_hard_selected() -> void:
	Global.difficulty = 0
	set_difficulty_description()

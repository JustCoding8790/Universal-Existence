extends Panel
@onready var credits: Panel = $"."
@onready var back_button: Button = $Back
@onready var settings_exit: Button = $"../Settings/Exit"
@onready var credits_player: AnimationPlayer = $CreditsPlayer

# --------------------
# OPEN/CLOSE
# --------------------

func credits_open() -> void:
	back_button.disabled = true
	settings_exit.disabled = true
	credits.visible = true
	credits_player.play("open")
	await credits_player.animation_finished
	back_button.disabled = false

func _on_credits_back_pressed() -> void:
	back_button.disabled = true
	credits_player.play("close")
	await credits_player.animation_finished
	credits.visible = false
	settings_exit.disabled = false

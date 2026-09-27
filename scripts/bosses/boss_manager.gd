extends Node2D

signal bee_good_created
signal player_defeated
signal boss_defeated
var emitted_defeated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_meta("Enemies_Left") < 1 and not emitted_defeated:
		boss_defeated.emit()
		emitted_defeated = true

func _on_bee_good_created(bee_good: Area2D) -> void:
	bee_good.player_died.connect(_on_player_died)

func _on_player_died(body, voicelines) -> void:
	player_defeated.emit(body, voicelines)

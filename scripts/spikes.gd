extends Area2D

signal player_died

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		player_died.emit(body)

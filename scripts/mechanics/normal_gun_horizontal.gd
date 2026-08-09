extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		body.start_shooting("horizontal")
		queue_free()

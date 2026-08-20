extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		if "Normal" in self.name:
			if "Horizontal" in self.name:
				body.start_shooting("normal", "horizontal")
			elif "Up" in self.name:
				body.start_shooting("normal", "up")
			elif "Down" in self.name:
				body.start_shooting("normal", "down")
		queue_free()

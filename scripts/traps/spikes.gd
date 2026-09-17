extends Area2D

signal player_died

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		var voicelines = []
		Global.deaths["spikes"] += 1
		if Global.deaths["spikes"] == 1:
			voicelines.append(["Spiked!", 1])
		elif Global.deaths["spikes"] == 3:
			voicelines.append(["Training isn't easy, jumper.", 2])
		elif Global.deaths["spikes"] == 6:
			voicelines.append(["By the way, you can jump higher by holding the jump button for longer.", 3.5])
			voicelines.append(["Try making good use of that next time.", 2.5])
		player_died.emit(body, voicelines)

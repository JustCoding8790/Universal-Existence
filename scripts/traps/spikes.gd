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
		elif Global.deaths["spikes"] == 5:
			voicelines.append(["By the way, you can jump higher by holding the jump button for longer.", 3.5])
			voicelines.append(["Try making good use of that next time.", 2.5])
		elif Global.deaths["spikes"] == 8:
			voicelines.append(["If you can't handle this, later levels might be problem.", 2.5])
			voicelines.append(["There's going to be lots of moving enemies that can shoot bullets at you.", 3])
			voicelines.append(["And you're having trouble with a stationary triangle in the ground.", 3])
			voicelines.append(["I repeat...", 0.5])
			voicelines.append(["A STATIONARY TRIANGLE IN THE GROUND!", 1.5])
		elif Global.deaths["spikes"] == 12:
			voicelines.append(["Still a problem, huh?", 1.5])
			voicelines.append(["Although you probably have other things to be worrying about by now...", 3])
		elif Global.deaths["spikes"] == 16:
			voicelines.append(["You know, I wonder how spikes kill people.", 2])
			voicelines.append(["In reality, they simply hurt your foot, but nothing else...", 3])
		player_died.emit(body, voicelines)

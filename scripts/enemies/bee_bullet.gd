extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var SPEED = 300
var speeds = [140, 180, 220, 260]
var bee_good_owner = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SPEED = speeds[Global.difficulty]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.y += SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		body.die()
		if bee_good_owner:
			Global.deaths["bossbee"] += 1
			if Global.deaths["bossbee"] == 2:
				print("Is the number of bullets being fired at once overwhelming for you?")
				print("Well, don't worry. That's exactly what I intended.")
				print("Training isn't easy, jumper.")
			elif Global.deaths["bossbee"] == 5:
				print("She's a good one, ain't she?")
			elif Global.deaths["bossbee"] == 8:
				print("Oof. Must've stung you a lot to die to that.")
			elif Global.deaths["bossbee"] == 12:
				print("Okay, it's starting to get old.")
				print("Maybe consider switching to a lower difficulty for now.")
		else:
			Global.deaths["bees"] += 1
			if Global.deaths["bees"] == 3:
				print("What a bee-ting that was...")
				print("Hey, let me make my jokes!")
		queue_free()
	elif body.name == "TileMapLayer":
		queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

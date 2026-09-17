extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_timer: Timer = $Timer

var speed = 50
var direction = -1
var speeds = [20, 35, 50, 60]
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "Flip" in self.name:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	speed = speeds[Global.difficulty]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta * self.scale.x

#func _on_timer_timeout() -> void:
#	direction *= 1
#	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		var voicelines = []
		Global.deaths["snails"] += 1
		if Global.deaths["snails"] == 2:
			voicelines.append(["Honestly, they're not as slow as they seem.", 2])
		elif Global.deaths["snails"] == 3:
			voicelines.append(["Looking for an easy way to counter snails?", 2])
			voicelines.append(["It's called \"double-jumping\".", 1])
		elif Global.deaths["trunks"] == 5:
			voicelines.append(["Snail county, tis of thee...", 2.5])
			voicelines.append(["In forgetting the lyrics to this sympathy...", 2.5])
		elif Global.deaths["snails"] == 7:
			voicelines.append(["Fun fact: these snails are actually from Fantasy Isles.", 2.5])
			voicelines.append(["You'll encounter them there too.", 1.5])
		player_died.emit(body, voicelines)
	elif body.name == "TileMapLayer" or body.name == "CollisionShape2D":
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

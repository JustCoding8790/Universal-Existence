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
		player_died.emit(body)
	elif body.name == "TileMapLayer" or body.name == "CollisionShape2D":
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

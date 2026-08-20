extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var SPEED = 360
var speeds = [120, 180, 220, 280]
var direction = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SPEED = speeds[Global.difficulty]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.x += direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		body.die()
		queue_free()
	elif body.name == "TileMapLayer":
		queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

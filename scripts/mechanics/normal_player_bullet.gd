extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var SPEED = 300
var direction = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.x += direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if "Trunkwalker" in area.name:
		if area.health > 0:
			area.take_damage(4)
			queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

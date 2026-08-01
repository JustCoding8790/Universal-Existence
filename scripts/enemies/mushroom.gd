extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var vulnerable_shape_2d: CollisionShape2D = $VulnerableShape2D

var speed = 50
var direction = -1
var speeds = [20, 35, 50, 60]
var alive = true
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "Flip" in self.name:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	speed = speeds[Global.difficulty]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * speed * delta * self.scale.x

#func _on_timer_timeout() -> void:
#	direction *= 1
#	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner_id = shape_find_owner(local_shape_index)
	var hit_shape_node = shape_owner_get_owner(shape_owner_id)
	if hit_shape_node == vulnerable_shape_2d:
		if body.name == "Player" and body.alive and body.velocity.y > 0:
			alive = false
			body.jump_boost()
			animated_sprite_2d.animation = "hit"
			await animated_sprite_2d.animation_finished
			queue_free()
	elif hit_shape_node == collision_shape_2d and alive:
		if body.name == "Player" and body.alive:
			player_died.emit(body)
		elif body.name == "TileMapLayer" or body.name == "CollisionShape2D":
			direction *= -1
			animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

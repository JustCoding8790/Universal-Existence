extends Area2D
@onready var trunkwalker: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_timer: Timer = $ShootingCooldown
@onready var projectile = load("res://scenes/enemies/trunk_bullet.tscn")
var speed = 50
var direction = -1
var speeds = [35, 50, 60, 75]
var shoot_intervals = [3, 2, 1.5, 1]
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "Flip" in self.name:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	speed = speeds[Global.difficulty]
	shooting_timer.wait_time = shoot_intervals[Global.difficulty]
	shooting_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animated_sprite_2d.animation == "walk":
		position.x += direction * speed * delta * self.scale.x

func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()
	animated_sprite_2d.animation = "shoot"
	await animated_sprite_2d.animation_finished
	var bullet = projectile.instantiate()
	bullet.visible = false
	get_tree().get_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.scale = trunkwalker.scale
	bullet.direction = direction
	if direction == -1:
		bullet.global_position.x -= 15
		bullet.sprite_2d.flip_h = true
	else:
		bullet.global_position.x += 15
	bullet.visible = true
	animated_sprite_2d.animation = "walk"
	animated_sprite_2d.play()
	shooting_timer.start()
	# print("Projectile spawned")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		player_died.emit(body)
	elif body.name == "TileMapLayer" or body.name == "CollisionShape2D":
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

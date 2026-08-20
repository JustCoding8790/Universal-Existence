extends Area2D
@onready var bee: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_timer: Timer = $ShootingTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var projectile = load("res://scenes/enemies/bee_bullet.tscn")
@onready var hit_sound: AudioStreamPlayer = $HitSound

var speed = 100
var direction = -1
var speeds = [65, 75, 90, 100]
var min_shoot_intervals = [2, 1.5, 1, 0.5]
var max_shoot_intervals = [3, 2.5, 2, 1.5]
var health = 20
var hp_amounts = [12, 15, 16, 20]
var self_alive = true
var speed_multiplier = 1
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "Flip" in self.name:
		direction *= -1
	speed = randi_range(speeds[Global.difficulty] - 10, speeds[Global.difficulty] + 10)
	patrol_timer.wait_time = bee.get_meta("Patrol_Time")
	shooting_timer.wait_time = randf_range(min_shoot_intervals[Global.difficulty], max_shoot_intervals[Global.difficulty])
	patrol_timer.start()
	shooting_timer.start()
	health = hp_amounts[Global.difficulty]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if patrol_timer.time_left <= 0.5 or patrol_timer.time_left >= bee.get_meta("Patrol_Time") - 0.5:
		speed_multiplier = min(patrol_timer.time_left * 2, (bee.get_meta("Patrol_Time") - patrol_timer.time_left) * 2)
	else:
		speed_multiplier = 1
	position.x += direction * speed * delta * self.scale.x * speed_multiplier

func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()
	animated_sprite_2d.animation = "shoot"
	await animated_sprite_2d.animation_finished
	var bullet = projectile.instantiate()
	bullet.visible = false
	get_tree().get_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.scale = bee.scale
	if direction == -1:
		bullet.global_position.x -= 8
	else:
		bullet.global_position.x += 8
	bullet.global_position.y += 16
	if health <= 0:
		bullet.queue_free()
	bullet.visible = true
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	shooting_timer.wait_time = randf_range(min_shoot_intervals[Global.difficulty], max_shoot_intervals[Global.difficulty])
	shooting_timer.start()
	# print("Projectile spawned")

func _on_patrol_timer_timeout() -> void:
	direction *= -1
	speed = randi_range(speeds[Global.difficulty] - 25, speeds[Global.difficulty] + 25)
	patrol_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive and self_alive:
		player_died.emit(body)

func take_damage(damage: int) -> void:
	hit_sound.play()
	health -= damage
	if health <= 0:
		shooting_timer.stop()
		self_alive = false
		animated_sprite_2d.animation = "hit"
		await animated_sprite_2d.animation_finished
		queue_free()

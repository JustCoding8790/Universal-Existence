extends Area2D
@onready var plant: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_timer: Timer = $ShootingCooldown
@onready var projectile = load("res://scenes/enemies/plant_bullet.tscn")
@onready var hit_sound: AudioStreamPlayer = $HitSound

var speed = 50
var direction = -1
var min_shoot_intervals = [2.5, 2, 1.25, 0.5]
var max_shoot_intervals = [5, 3.5, 2.75, 2]
var min_delay
var max_delay
var health = 80
var hp_amounts = [65, 75, 90, 100]
var self_alive = true
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "Flip" in self.name:
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	min_delay = plant.get_meta("Min_Delay")
	max_delay = plant.get_meta("Max_Delay")
	shooting_timer.wait_time = randf_range(min_shoot_intervals[Global.difficulty] + min_delay, max_shoot_intervals[Global.difficulty] + max_delay)
	shooting_timer.start()
	health = hp_amounts[Global.difficulty]

func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()
	animated_sprite_2d.animation = "shoot"
	await animated_sprite_2d.animation_finished
	var bullet = projectile.instantiate()
	bullet.visible = false
	get_tree().get_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.scale = plant.scale
	bullet.direction = direction
	if direction == -1:
		bullet.global_position.x -= 15
		bullet.sprite_2d.flip_h = true
	else:
		bullet.global_position.x += 15
	bullet.global_position.y -= 12
	if health <= 0:
		bullet.queue_free()
	bullet.visible = true
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	shooting_timer.wait_time = randf_range(min_shoot_intervals[Global.difficulty] + min_delay, max_shoot_intervals[Global.difficulty] + max_delay)
	shooting_timer.start()
	# print("Projectile spawned")

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

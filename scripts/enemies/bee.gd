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
	bullet.player_shot.connect(bullet_shot_player)
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
		Global.deaths["bees"] += 1
		var voicelines = []
		'''if Global.deaths["bees"] == 1:
			voicelines.append(["Ok, why'd you think colliding into them was a good idea?", 4])
		if Global.deaths["bees"] == 3:
			voicelines.append(["Please stop colliding with the bees...", 2.5])
			voicelines.append(["What are you trying to do?", 1.5])'''
		player_died.emit(body, voicelines)

func take_damage(damage: int) -> void:
	hit_sound.play()
	health -= damage
	if health <= 0:
		shooting_timer.stop()
		self_alive = false
		animated_sprite_2d.animation = "hit"
		await animated_sprite_2d.animation_finished
		queue_free()

func bullet_shot_player(body) -> void:
	var voicelines = []
	Global.deaths["bees"] += 1
	if Global.deaths["bees"] == 1:
		voicelines.append(["Those bees sure do sting...", 2])
		voicelines.append(["But they won't last long when you \"sting\" them back.", 3])
	elif Global.deaths["bees"] == 3:
		voicelines.append(["What a bee-ting!", 1.5])
		voicelines.append(["Hey, let me make my jokes!", 2])
	elif Global.deaths["bees"] == 5:
		voicelines.append(["Honestly, I'm scared of bees.", 1.5])
		voicelines.append(["I had to run on a sidewalk with a long bush...", 2])
		voicelines.append(["And bees were EVERYWHERE around that bush.", 2])
		voicelines.append(["So hey, if you get scared of bees after this, just know I'm here for you.", 3.5])
	elif Global.deaths["bees"] == 8:
		voicelines.append(["You know, I had some high hopes you'll past the last challenge of the test.", 3.5])
		voicelines.append(["But honestly, we might need to downgrade the difficulty.", 3])
	player_died.emit(body, voicelines)

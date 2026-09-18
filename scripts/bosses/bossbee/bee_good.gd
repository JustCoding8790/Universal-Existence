extends Area2D
@onready var bee: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_timer: Timer = $ShootingTimer
@onready var accel_timer: Timer = $AccelTimer
@onready var deaccel_timer: Timer = $DeaccelTimer
@onready var projectile = load("res://scenes/enemies/bee_bullet.tscn")
@onready var bee_good_copy = load("res://scenes/bosses/bossbee/bee_good.tscn")
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var enemies: Node2D = $".."

var plant_left: Area2D
var plant_right: Area2D

var direction = 1
var speeds = [45, 55, 60, 75]
var speed = speeds[Global.difficulty]
var min_shoot_intervals = [1.75, 1.25, 0.75, 0.375]
var max_shoot_intervals = [2.25, 1.75, 1.25, 0.875]
var hp_amounts = [8, 8, 12, 12]
var health = hp_amounts[Global.difficulty]
var self_alive = true
var speed_multiplier = 1
var acceling = false
var deacceling = false
var defeated = false
var former_speed
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plant_left = get_node_or_null("../PoisonPlant")
	plant_right = get_node_or_null("../PoisonPlant2Flip")
	shooting_timer.wait_time = randf_range(min_shoot_intervals[Global.difficulty], max_shoot_intervals[Global.difficulty])
	shooting_timer.start()

func flip_initial_dir() -> void:
	direction = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if deacceling and deaccel_timer.time_left <= 0.5:
		speed_multiplier = deaccel_timer.time_left * 2
	elif acceling and accel_timer.time_left <= 0.5:
		speed_multiplier = 1 - accel_timer.time_left * 2
	else:
		speed_multiplier = 1
	position.x += direction * speed * delta * (8 - self.scale.x) * speed_multiplier

func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()
	animated_sprite_2d.animation = "shoot"
	await animated_sprite_2d.animation_finished
	var bullet = projectile.instantiate()
	bullet.bee_good_owner = true
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

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "BossBounds":
		deaccel_timer.start()
		deacceling = true

func _on_deaccel_timer_timeout() -> void:
	deacceling = false
	direction *= -1
	accel_timer.start()
	acceling = true
	
func _on_accel_timer_timeout() -> void:
	acceling = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive and self_alive:
		var voicelines = []
		Global.deaths["bossbee"] += 1
		'''if Global.deaths["bossbee"] == 1:
			voicelines.append(["How'd you even manage to collide with her in the first place?", 3])
		elif Global.deaths["bossbee"] == 4:
			voicelines.append(["I know you have to be doing this intentionally.", 2])
			voicelines.append(["...Right?", 1])
		elif Global.deaths["bossbee"] == 12:
				voicelines.append(["Okay, it's starting to get old.", 2])
				voicelines.append(["Maybe consider switching to a lower difficulty for now.", 3])'''
		player_died.emit(body, voicelines)

func take_damage(damage: int) -> void:
	hit_sound.play()
	health -= damage
	if health <= 0:
		shooting_timer.stop()
		self_alive = false
		enemies.set_meta("Enemies_Left", enemies.get_meta("Enemies_Left") - 1)
		if scale.x <= 2 and enemies.get_meta("Enemies_Left") == 0:
			defeated = true
			former_speed = Engine.time_scale
			Engine.time_scale = Engine.time_scale / 5
			plant_left.animated_sprite_2d.animation = "hit"
			plant_right.animated_sprite_2d.animation = "hit"
		animated_sprite_2d.animation = "hit"
		await animated_sprite_2d.animation_finished
		if scale.x > 2:
			var copy_diff = randf_range(10, 20)
			var bee_copy1 = bee_good_copy.instantiate()
			bee_copy1.position.x = global_position.x - 30
			bee_copy1.position.y = global_position.y + copy_diff
			bee_copy1.scale.x = scale.x - 1
			bee_copy1.scale.y = scale.y - 1
			bee_copy1.name = "Bee Good " + str(scale.x) + str(enemies.get_meta("Enemy_Count"))
			bee_copy1.flip_initial_dir()
			enemies.add_child(bee_copy1)
			var bee_copy2 = bee_good_copy.instantiate()
			bee_copy2.position.x = global_position.x + 30
			bee_copy2.position.y = global_position.y + copy_diff + randf_range(10, 20)
			bee_copy2.scale.x = scale.x - 1
			bee_copy2.scale.y = scale.y - 1
			bee_copy2.name = "Bee Good " + str(scale.x) + str(enemies.get_meta("Enemy_Count") + 1)
			enemies.add_child(bee_copy2)
			enemies.set_meta("Enemy_Count", enemies.get_meta("Enemy_Count") + 2)
			# print(bee_copy1.name)
			# print(bee_copy2.name)
		animated_sprite_2d.animation = "disappear"
		animated_sprite_2d.play()
		await animated_sprite_2d.animation_finished
		if scale.x <= 2 and defeated:
			if Global.difficulty >= 2:
				plant_left.queue_free()
				plant_right.queue_free()
			Engine.time_scale = former_speed
		# print(enemies.get_meta("Enemies_Left"))
		Global.bee_good_diff = Global.difficulty
		Global.demo_time = Time.get_ticks_msec()
		queue_free()

func bullet_shot_player(body) -> void:
	var voicelines = []
	Global.deaths["bossbee"] += 1
	if Global.deaths["bossbee"] == 2:
		voicelines.append(["Is the number of bullets being fired at once overwhelming for you?", 3])
		voicelines.append(["Well, don't worry. That's exactly what I intended.", 3])
	elif Global.deaths["bossbee"] == 4:
		voicelines.append(["She's a good one, ain't she?", 2])
	elif Global.deaths["bossbee"] == 7:
		voicelines.append(["Don't focus too much on shooting the boss, my friend...", 3])
		voicelines.append(["Most of your bullets will probably hit her anyways.", 2.5])
		voicelines.append(["Focus on dodging for now.", 1.5])
	elif Global.deaths["bossbee"] == 9:
		voicelines.append(["Oof. Must've stung you a lot to die to that.", 3])
	'''elif Global.deaths["bossbee"] == 12:
		voicelines.append(["Okay, it's starting to get old.", 1.5])
		voicelines.append(["Maybe consider switching to a lower difficulty for now.", 2.5])'''
	player_died.emit(body, voicelines)

extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var main: Node2D = $"../.."
@onready var shooting_timer: Timer = $ShootingTimer
@onready var projectile = load("res://scenes/mechanics/normal_player_bullet.tscn")
# @onready var floor_cast: ShapeCast2D = $FloorShapeCast2D

var SPEED = 150.0
var JUMP_VELOCITY = -315.0
const MAX_JUMPS = 2
var jump_buffer_timer = 0.0
const JUMP_BUFFER_TIME = 0.15
var coyote_timer = 0.0
const COYOTE_TIME = 2
var jump_multiplier = 1
var gravity_multiplier = 1
var direction

var jump_count = 0
var double_jump_anim_playing = false
var holding_jump = false
var alive = true
var can_move = true

var base_gravity = 1875
var hold_gravity_scale = 0.5
var jump_cut_multiplier = 0.45

var shoot_mode = ""
var shoot_dir = ""

func _ready() -> void:
	# Connect main
	main.reset_gravity.connect(_reset_vertical_gravity)

func jump_boost() -> void:
	velocity.y = JUMP_VELOCITY * self.scale.x * 1.35
	jump_sound.play()
	jump_count = 1
	double_jump_anim_playing = false

# --------------------
# MOVEMENT
# --------------------

func _physics_process(delta: float) -> void:
	if !alive:
		return
	# Add animation
	if not double_jump_anim_playing:
		if velocity.x > 1 or velocity.x < -1:
			animated_sprite_2d.animation = "run"
		else:
			animated_sprite_2d.animation = "idle"
		
	# Add the gravity.
	if not is_on_floor():
		var gravity = base_gravity * gravity_multiplier
		#if Input.is_action_pressed("jump") and velocity.y < 0:
			#gravity += hold_gravity_scale
		velocity.y += gravity * delta
		if jump_count == 0:
			animated_sprite_2d.animation = "fall"
		elif jump_count == 1:
			animated_sprite_2d.animation = "jump"
		elif jump_count == 2 and not double_jump_anim_playing:
			animated_sprite_2d.animation = "double_jump"
			double_jump_anim_playing = true
	elif jump_count != 0:
		jump_count = 0
		double_jump_anim_playing = false

	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump"):
			if jump_count < MAX_JUMPS:
				# jump adjustments (at scale 1.5, jump movement feels too heavy)
				velocity.y = JUMP_VELOCITY * self.scale.x * jump_multiplier
				jump_sound.play()
				jump_count += 1
			else:
				jump_buffer_timer = JUMP_BUFFER_TIME
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cut_multiplier
		# Buffer and coyote time
		if jump_buffer_timer > 0:
			jump_buffer_timer -= delta
			if (is_on_floor() or coyote_timer > 0) and jump_count < MAX_JUMPS:
				velocity.y = JUMP_VELOCITY * self.scale.x * jump_multiplier
				jump_sound.play()
				jump_count += 1
				jump_buffer_timer = 0
				coyote_timer = 0
		if is_on_floor():
			coyote_timer = COYOTE_TIME
		else:
			coyote_timer -= delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = min(direction * SPEED * self.scale.x, direction * SPEED * self.scale.x * Global.sensitivity_multi)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * self.scale.x)
		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true

func die() -> void:
	Global.total_deaths += 1
	animated_sprite_2d.animation = "hit"
	alive = false
	death_sound.play()
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.animation = "disappear"
	animated_sprite_2d.play()
	main._load_level(Global.world, Global.level, false, true)

func _reset_vertical_gravity() -> void:
	ProjectSettings.set_setting("physics/2d/default_gravity", 1250 * self.scale.x * gravity_multiplier)

# --------------------
# SHOOTING
# --------------------

func start_shooting(type: String, dir: String) -> void:
	shooting_timer.start()
	shoot_mode = type
	shoot_dir = dir

func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()
	if shoot_mode == "normal":
		var bullet = projectile.instantiate()
		# bullet.visible = false
		get_tree().get_root().add_child(bullet)
		bullet.global_position = global_position
		bullet.scale = self.scale
		if shoot_dir == "horizontal":
			if animated_sprite_2d.flip_h:
				bullet.global_position.x -= 15
				bullet.sprite_2d.flip_h = true
				bullet.direction = -1
			else:
				bullet.global_position.x += 15
				bullet.direction = 1
		elif shoot_dir == "up":
			bullet.global_position.y -= 15
			bullet.direction = 2
			bullet.rotation = deg_to_rad(-90)
		# bullet.visible = true
		shooting_timer.start()

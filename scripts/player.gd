extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var main: Node2D = $"../.."

var SPEED = 150.0
var JUMP_VELOCITY = -350.0
const MAX_JUMPS = 2
var jump_buffer_timer = 0.0
const JUMP_BUFFER_TIME = 0.2
var coyote_timer = 0.0
const COYOTE_TIME = 20
var jump_multiplier = 1.1

var jump_count = 0
var double_jump_anim_playing = false
var alive = true
var can_move = true

func _ready() -> void:
	# Connect main
	main.reset_gravity.connect(_reset_vertical_gravity)

func jump_boost() -> void:
	velocity.y = JUMP_VELOCITY * self.scale.x * 1.35
	jump_sound.play()
	jump_count = 1

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
		velocity += get_gravity() * delta
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
		if Input.is_action_just_pressed("jump") and jump_count >= 1 and jump_count < MAX_JUMPS:
			# jump adjustments (at scale 1.5, jump movement feels too heavy)
			velocity.y = JUMP_VELOCITY * self.scale.x * jump_multiplier
			jump_sound.play()
			jump_count += 1
		elif Input.is_action_just_pressed("jump"):
			jump_buffer_timer = JUMP_BUFFER_TIME

		if jump_buffer_timer > 0:
			jump_buffer_timer -= delta
		if is_on_floor():
			coyote_timer = COYOTE_TIME
		else:
			coyote_timer -= delta
		if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
			velocity.y = JUMP_VELOCITY * self.scale.x * jump_multiplier
			jump_sound.play()
			jump_count += 1
			jump_buffer_timer = 0
			coyote_timer = 0

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED * self.scale.x
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * self.scale.x)

		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true

func die() -> void:
	animated_sprite_2d.animation = "hit"
	alive = false
	death_sound.play()

func _reset_vertical_gravity() -> void:
	ProjectSettings.set_setting("physics/2d/default_gravity", 1250 * self.scale.x)
	if self.scale.x == 1.5:
		jump_multiplier = 1.1
	else:
		jump_multiplier = 1

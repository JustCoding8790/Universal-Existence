extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

const SPEED = 300.0
const JUMP_VELOCITY = -650.0
const MAX_JUMPS = 2

var jump_count = 0
var double_jump_anim_playing = false
var alive = true
var can_move = true

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
		if jump_count == 1:
			animated_sprite_2d.animation = "jump"
		elif jump_count == 2 and not double_jump_anim_playing:
			animated_sprite_2d.animation = "double_jump"
			double_jump_anim_playing = true
	elif jump_count != 0:
		jump_count = 0
		double_jump_anim_playing = false

	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < MAX_JUMPS):
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			jump_count += 1

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true

func die() -> void:
	animated_sprite_2d.animation = "hit"
	alive = false
	death_sound.play()

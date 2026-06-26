extends Node2D
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var fade: ColorRect = $HUD/Fade

var score: int = 0
var prev_score: int = 0

var world: int = 1	# implement different worlds later
var level: int = 1
var current_level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(world, level, true, false)

# --------------------
# LEVEL MANAGEMENT
# --------------------

func _load_level(world_number: int, level_number: int, first_load: bool, reset_score: bool) -> void:
	# Fade out
	if not first_load:
		await _fade(1.0)
	
	if reset_score:
		score = prev_score
		score_label.text = "SCORE\n%s" % prev_score
	else: 
		prev_score = score
	
	# Delete current level
	if current_level_root:
		current_level_root.queue_free()
	
	# Change level
	var level_path = "res://scenes/levels/level_%s-%s.tscn" % [world_number, level_number]
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	
	# Fade in
	await _fade(0.0)

func _setup_level(level_root: Node) -> void:
	# Connect exit
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	# Connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)

	# Connect collectibles
	var apples = level_root.get_node_or_null("Apples")
	if apples:
		for apple in apples.get_children():
			apple.collected.connect(increase_score.bind(1))
	var melons = level_root.get_node_or_null("Melons")
	if melons:
		for melon in melons.get_children():
			melon.collected.connect(increase_score.bind(2))

# --------------------
# SIGNAL HANDLERS
# --------------------

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# print(body.name)
		level += 1
		body.can_move = false
		await _load_level(world, level, false, false)

func _on_player_died(body) -> void:
	body.die()
	await _load_level(world, level, false, true)

# --------------------
# SCORE
# --------------------

func increase_score(amount: int) -> void:
	score += amount
	print(score)
	score_label.text = "SCORE\n%s" % score

# --------------------
# FADE
# --------------------

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 0.5)
	await tween.finished

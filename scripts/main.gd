extends Node2D
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var fade: ColorRect = $HUD/Fade
@onready var voice_captions: Label = $HUD/VoiceCaptions

var score: int = 0
var prev_score: int = 0
var voiceline_active = false
var voiceline_queue = []

var current_level_root: Node = null

signal reset_gravity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(Global.world, Global.level, true, false)

func _process(delta: float) -> void:
	if len(voiceline_queue) > 0 and not voiceline_active:
		voiceline_active = true
		voice_captions.visible = true
		print(voiceline_queue[0][0])
		voice_captions.text = voiceline_queue[0][0]
		await get_tree().create_timer(voiceline_queue[0][1]).timeout
		voiceline_queue.remove_at(0)
		voice_captions.visible = false
		await get_tree().create_timer(0.25).timeout
		voiceline_active = false
	elif not voiceline_active:
		voice_captions.visible = false

# --------------------
# LEVEL MANAGEMENT
# --------------------

func _load_level(world_number: int, level_number: int, first_load: bool, reset_score: bool) -> void:
	# Prevent pausing during loading
	Global.can_pause = false
	
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
	var level_path = "res://scenes/levels/level_%s-%s_%s.tscn" % [world_number, level_number, Global.difficulty]
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	reset_gravity.emit()
	if world_number == 1 and level_number == 1:
		voiceline_queue.append(["...", 2])
		voiceline_queue.append(["Oh! A jumper arrived!", 1.5])
		voiceline_queue.append(["Hey there! Welcome to the UPC!", 1.5])
		voiceline_queue.append(["You know, the Universal Platforming Course.", 2])
		voiceline_queue.append(["Wanted to prepare for the inevitable big threat that will strike the universe one day?", 4])
		voiceline_queue.append(["Then you came to the right place!", 2])
		print(len(voiceline_queue))
	elif world_number == 1 and level_number == 2:
		voiceline_queue.append(["Ever heard of jumping while you fall?", 2])
		voiceline_queue.append(["Try it out!", 1])
	elif world_number == 1 and level_number == 3:
		voiceline_queue.append(["Just collect the apples for points. Simple.", 2])
		voiceline_queue.append(["Not like there's any other fruits around...", 2])
	elif world_number == 1 and level_number == 4:
		voiceline_queue.append(["You know 'em. You love 'em. They're spikes.", 2])
		voiceline_queue.append(["Or, well... the bane of a platformer's existence.", 2])
	elif world_number == 1 and level_number == 5:
		voiceline_queue.append(["Watch where you go or you'll be SNAILed! Ha!", 2])
		voiceline_queue.append(["Sorry. Just avoid them.", 1.5])
	elif world_number == 1 and level_number == 6:
		voiceline_queue.append(["Time for a snail party! Complete with a...", 2.5])
		voiceline_queue.append(["...what are you supposed to be anyways?", 2])
	elif world_number == 1 and level_number == 7:
		voiceline_queue.append(["Behold, it's the Pit of Doom!", 1.5])
		voiceline_queue.append(["Wait, since when could they walk on spikes?", 2])
	# Fade in
	await _fade(0.0)
	Global.can_pause = true

func _setup_level(level_root: Node) -> void:
	# Connect exit
	var pause_menu = level_root.get_node_or_null("Player").get_node_or_null("Pause")
	if pause_menu:
		pause_menu.difficulty_changed.connect(_load_level)

	# Connect exit
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	# Connect traps
	var traps = level_root.get_node_or_null("Traps")
	if traps:
		for trap in traps.get_children():
			trap.player_died.connect(_on_player_died)
	
	# Connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
		if enemies.has_meta("Enemies_Left"):
			enemies.boss_defeated.connect(_on_boss_defeated)
	
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
		if Global.training:
			body.can_move = false
			await _load_level(Global.world, Global.level, false, true)
		else:
			# print(body.name)
			Global.level += 1
			body.can_move = false
			await _load_level(Global.world, Global.level, false, false)

func _on_player_died(body, voicelines) -> void:
	body.die()
	if len(voicelines) > 0:
		for line in voicelines:
			voiceline_queue.append([line[0], line[1]])

func _on_boss_defeated() -> void:
	await get_tree().create_timer(3).timeout
	Global.level += 1
	await _load_level(Global.world, Global.level, false, true)

# --------------------
# SCORE
# --------------------

func increase_score(amount: int) -> void:
	# Amount depends on collectible
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

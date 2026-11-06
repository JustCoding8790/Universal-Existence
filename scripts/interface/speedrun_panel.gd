extends Panel
@onready var speedrun_timer: Label = $SpeedrunTimer

var elapsed_ms = 0
var hours = 0
var minutes = 0
var seconds = 0
var milliseconds = 0

func _ready():
	pass

func _process(_delta):
	if Global.speedrun_timer_running and Global.player_moved:
		elapsed_ms = Time.get_ticks_msec() - Global.speedrun_off_time
		hours = elapsed_ms / 3600000
		minutes = (elapsed_ms % 3600000) / 60000
		seconds = (elapsed_ms % 60000) / 1000
		milliseconds = elapsed_ms % 1000
	else:
		Global.speedrun_off_time = Time.get_ticks_msec() - elapsed_ms
	if Global.speedrun_timer_on:
		speedrun_timer.text = "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
		self.visible = true
	else:
		self.visible = false

func start_timer() -> void:
	Global.speedrun_off_time = Time.get_ticks_msec() - elapsed_ms
	Global.speedrun_timer_running = true

func stop_timer() -> void:
	Global.speedrun_off_time = Time.get_ticks_msec() - elapsed_ms
	Global.speedrun_timer_running = false

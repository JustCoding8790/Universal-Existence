extends Panel
@onready var speedrun_timer: Label = $SpeedrunTimer
'''
var start_time: int
var is_running: bool = false

func _ready():
	start_timer()

func start_timer():
	Global.speedrun_timer_running = true
	start_time = Time.get_ticks_msec()

func stop_timer():
	Global.speedrun_timer_running = false

func _process(_delta):
	if Global.speedrun_timer_running:
		var elapsed_ms = Time.get_ticks_msec() - start_time
		var hours = elapsed_ms / 1000
		var minutes = (elapsed_ms % 1000) / 60000
		var seconds = (elapsed_ms % 60000) / 1000
		var milliseconds = (elapsed_ms % 1000) / 10
		speedrun_timer.text = "$02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
'''

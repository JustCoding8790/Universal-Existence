extends Panel
@onready var speedrun_timer: Label = $SpeedrunTimer

func _ready():
	pass

func _process(_delta):
	if Global.speedrun_timer_on:
		var elapsed_ms = Time.get_ticks_msec()
		var hours = elapsed_ms / 3600000
		var minutes = (elapsed_ms % 3600000) / 60000
		var seconds = (elapsed_ms % 60000) / 1000
		var milliseconds = elapsed_ms % 1000
		speedrun_timer.text = "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
		self.visible = true
	else:
		self.visible = false

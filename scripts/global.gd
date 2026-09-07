extends Node

# --------------------
# GLOBAL STATS
# --------------------
var difficulty = 0
var can_pause = false
var world: int = 1	# implement different worlds later
var level: int = 1

var bee_good_diff
var demo_time
var fruits = [0, 0]	# [apples, melons]
var total_deaths = 0
var deaths = {"spikes": 0, "snails": 0, "mushrooms": 0, "trunks": 0, "plants": 0, "bees": 0, "bossbee": 0}

# --------------------
# GLOBAL SETTINGS
# --------------------
var speedrun_timer_on = false
var speedrun_timer_running = true
var training = false
var sensitivity_multi = 1

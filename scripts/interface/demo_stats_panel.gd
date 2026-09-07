extends Panel
@onready var diff_label: Label = $LeftVBoxContainer/DiffLabel
@onready var apples_label: Label = $LeftVBoxContainer/ApplesLabel
@onready var melons_label: Label = $LeftVBoxContainer/MelonsLabel
@onready var time_label: Label = $LeftVBoxContainer/TimeLabel

@onready var spike_label: Label = $LeftVBoxContainer/SpikeLabel
@onready var snail_label: Label = $LeftVBoxContainer/SnailLabel
@onready var mushroom_label: Label = $RightVBoxContainer/MushroomLabel
@onready var trunk_label: Label = $RightVBoxContainer/TrunkLabel
@onready var plant_label: Label = $RightVBoxContainer/PlantLabel
@onready var bee_label: Label = $RightVBoxContainer/BeeLabel
@onready var bee_good_label: Label = $RightVBoxContainer/BeeGoodLabel
@onready var death_label: Label = $RightVBoxContainer/DeathLabel

var difficulties = ["Hard", "Extra Hard", "Ultra Hard", "Extreme"]
var hours = Global.demo_time / 3600000
var minutes = (Global.demo_time % 3600000) / 60000
var seconds = (Global.demo_time % 60000) / 1000
var milliseconds = Global.demo_time % 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	diff_label.text = "    Difficulty: " + difficulties[Global.bee_good_diff]
	apples_label.text = "    Apples: " + str(Global.fruits[0])
	melons_label.text = "    Melons: " + str(Global.fruits[1])
	time_label.text = "    Time: " + "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
	spike_label.text = "    Spike Deaths: " + str(Global.deaths["spikes"])
	snail_label.text = "    Snail Deaths: " + str(Global.deaths["snails"])
	mushroom_label.text = "Mushroom Deaths: " + str(Global.deaths["mushrooms"]) + "    "
	trunk_label.text = "Trunkwalker Deaths: " + str(Global.deaths["trunks"]) + "    "
	plant_label.text = "Plant Deaths: " + str(Global.deaths["plants"]) + "    "
	bee_label.text = "Bee Deaths: " + str(Global.deaths["bees"]) + "    "
	bee_good_label.text = "Bee Good Deaths: " + str(Global.deaths["bossbee"]) + "    "
	death_label.text = "Total Deaths: " + str(Global.total_deaths) + "    "

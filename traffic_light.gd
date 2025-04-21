extends Node2D

@onready var red_light = $TrafficLightContainer/RedLight
@onready var yellow_light =  $TrafficLightContainer/YellowLight
@onready var green_light = $TrafficLightContainer/GreenLight
@onready var light_timer = $LightTimer

var current_light

func _ready() -> void:
	red_light.modulate.a = 0.3
	yellow_light.modulate.a = 0.1
	green_light.modulate.a = 0.1


func change_to_red() -> void:
	yellow_light.modulate.a = 0.1
	green_light.modulate.a = 0.1
	red_light.modulate.a = 255
	current_light = "red"
	
func change_to_yellow() -> void:
	yellow_light.modulate.a = 1
	green_light.modulate.a = 0.1
	red_light.modulate.a = 0.3
	current_light = "yellow"

func change_to_green() -> void:
	yellow_light.modulate.a = 0.1
	green_light.modulate.a = 1
	red_light.modulate.a = 0.3
	current_light = "green"

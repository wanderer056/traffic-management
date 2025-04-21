extends Node

signal traffic_light_changed()

var current_light = LightTurn.light

enum LightTurn{
	light,
	light1,
	light2,
	light3
}


@onready var traffic_lights = get_tree().get_nodes_in_group("traffic_lights")
@onready var yellow_timer = $YellowTimer
@onready var light_timer = $LightTimer


func _ready() -> void:
	default_traffic_lights()

func next_light(p_current_light = current_light) -> LightTurn:
	match p_current_light:
		LightTurn.light:
			return LightTurn.light1
		
		LightTurn.light1:
			return LightTurn.light2
			
		LightTurn.light2:
			return LightTurn.light3
			
		LightTurn.light3:
			return LightTurn.light
			
	return LightTurn.light


func _on_light_timer_timeout() -> void:
	turn_yellow_lights()
	yellow_timer.start()


func turn_yellow_lights() -> void:
	traffic_lights[current_light].change_to_yellow()
	traffic_lights[next_light()].change_to_yellow()


func _on_yellow_timer_timeout() -> void:
	traffic_lights[current_light].change_to_red()
	traffic_lights[next_light()].change_to_green()
	current_light = next_light()
	traffic_light_changed.emit()
	light_timer.start()

func default_traffic_lights() -> void:
	for traffic_light in traffic_lights:
		traffic_light.change_to_red()
		
	traffic_lights[current_light].change_to_green()	
	light_timer.start()
	
func return_traffic_light(p_traffic_light) -> String:
	return p_traffic_light.current_light

class_name Car extends PathFollow2D

@export var speed_factor = 0.05
@export var max_speed = 0.1

var stop = false
var brake_factor 


func _ready() -> void:
	brake_factor = speed_factor / max_speed

func _process(p_delta) -> void:
	if stop:
#		speed_factor -= 0.1 * p_delta
		speed_factor = 0.0
		
#	elif $RayCast2D.is_colliding():
#		speed_factor = lerp(speed_factor,0.0,0.03)	
#
	else:
		speed_factor += 0.05 * p_delta
#	if speed_factor < 0:
#		speed_factor = 0
#
	if speed_factor > max_speed:
		speed_factor = max_speed
		
		
	
	progress_ratio += speed_factor * p_delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func stop_car(p_stop:bool) -> void:
	stop = p_stop


func _on_area_2d_area_entered(p_area) -> void:
	print("Area entered =", p_area)	
	stop = true



func _on_area_2d_area_exited(area):
	print("Area exited =", area)
	stop = false

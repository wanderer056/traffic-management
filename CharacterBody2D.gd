class_name CarBase extends CharacterBody2D

signal person_hit(p_collider)

@export var destination : Marker2D
@export var max_speed = 200.0
@export var friction = 0.06
@export var acceleration = 0.1
@export var steer_factor = 4

@onready var agent = $NavigationAgent2D
@onready var right_side_light_timer = $RightSideLightTimer
@onready var left_side_light_timer = $LeftSideLightTimer
@onready var right_side_light = $RightSideLight
@onready var left_side_light = $LeftSideLight

var brake = false
var speed = 0.0
var obstacle_detected: bool = false
var zebra_crossed: bool = false
var spawn_pos : String
var spawn_pos_node: Marker2D
var special_cases: bool = false
var value_right = 0
var value_left = 0
var turn: String
var near_crash = false
var destination_pos: Vector2
var temp_velocity := Vector2.ZERO
var move_sideways: bool = false
var side_movement_target : Vector2
var side_movement_speed = 100.0  # Adjust as needed


func _ready() -> void:
	if destination != null:
		agent.target_position = destination.global_position
	else:
		agent.target_position = destination_pos
	velocity = Vector2.ZERO
	set_turn()
	set_zebra_crossed_for_no_light_lanes()	
	turn_on_side_light()
	
	
func _physics_process(p_delta) ->void:
	for ray in get_children():
		if ray is RayCast2D:
#			if spawn_pos == "left" and ray.get_collision_point() != Vector2.ZERO and  ray.get_collision_point() > Vector2.ZERO:
#				print(global_position.distance_to(ray.get_collision_point()))
			if velocity.distance_to(Vector2.ZERO) > 50:
				ray.enabled = true
			if ray.is_colliding():
				obstacle_detected = true
				break
			else:
				obstacle_detected = false
				
	for ray in get_children():
		if ray is RayCast2D:
			if global_position.distance_to(ray.get_collision_point()) < 10:
#				velocity = Vector2.ZERO
				near_crash  = true
#				print(global_position.distance_to(ray.get_collision_point()))				
				break
			else:
				near_crash = false
		
	if obstacle_detected and $StopTimer.time_left == 0 and zebra_crossed:
		$StopTimer.start()
	
	
	if !brake and !obstacle_detected:
		if agent.is_navigation_finished():
			return

		var direction = global_position.direction_to(agent.get_next_path_position())

		speed = lerp(speed,max_speed,acceleration)
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * p_delta * steer_factor

		velocity += steering
	#	velocity = lerp(velocity,steering,accleration)
#		agent.set_velocity(velocity)
#		rotation = velocity.angle()
		rotation = lerp_angle(rotation,velocity.angle(),5.0 * p_delta)
#	elif move_sideways:
#		var move_direction = side_movement_target - global_position
#		if move_direction.length() > 10.0:
#			move_direction = move_direction.normalized()
#			velocity = move_direction * side_movement_speed
#			rotation = lerp_angle(rotation, velocity.angle(), 5.0 * p_delta)
#		else:
#			move_sideways = false
#			brake_car(false)
#			velocity = Vector2.ZERO
#			temp_velocity = Vector2.ZERO
#			rotation = velocity.angle()
	
	else:
		speed = 0.0
		velocity= lerp(velocity,Vector2.ZERO,friction)


#	if get_slide_collision_count() > 0:
#		print(get_slide_collision_count())
#		velocity = Vector2.ZERO
	
#	move_and_slide()
	var collision = move_and_collide((velocity + temp_velocity)*p_delta)
#	if collision:
#		print("I collided with ", collision.get_collider().name)
#		var collider = collision.get_collider()
#		if collider is CarBase:
#			velocity = Vector2.ZERO
#			collider.velocity = Vector2.ZERO
##			move_and_collide(velocity)
#			obstacle_detected = true
#			near_crash = true
	if collision != null:
		var collider = collision.get_collider()
		if collider is Person:
#			print("Collided with person")
#			collider.queue_free()
			person_hit.emit(collider)
			
#		if collider is Ambulance:
#			temp_velocity = Vector2(20,-10)
#			get_tree().create_timer(2.0).timeout.connect(_on_temp_vel_timeout)
#			print("Time : ", Time.get_unix_time_from_system(), "Ambulance Collision")
##			move_and_collide(velocity*p_delta)

func _on_temp_vel_timeout() -> void:
	temp_velocity = Vector2.ZERO


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func brake_car(p_brake:bool) -> void:
	brake = p_brake


func _on_stop_timer_timeout() -> void:
	for ray in get_children():
		if ray is RayCast2D:
			ray.enabled = false
	obstacle_detected = false


func set_zebra_corssed(p_zebra_crossed: bool) -> void:
	zebra_crossed = p_zebra_crossed


func set_zebra_crossed_for_no_light_lanes() -> void:
	if destination != null:
		if ("LP1" in spawn_pos_node.name and "TP1" in destination.name) or ("RP8" in spawn_pos_node.name and "BP2" in destination.name) or ("TP2" in spawn_pos_node.name and "RP1" in destination.name) or ("BP1" in spawn_pos_node.name and "LP8" in destination.name):
			special_cases = true
		
	if spawn_pos == "left" and turn == "left":
		special_cases = true


func set_turn() -> void:
	if (spawn_pos == "left" and "TP" in destination.name) or (spawn_pos == "right" and "BP" in destination.name) or (spawn_pos == "top" and "RP" in destination.name) or (spawn_pos == "bottom" and "LP" in destination.name):
		turn =  "left"
	elif (spawn_pos == "left" and "BP" in destination.name) or (spawn_pos == "right" and "TP" in destination.name) or (spawn_pos == "top" and "LP" in destination.name) or (spawn_pos == "bottom" and "RP" in destination.name):
		turn = "right"
	else:
		turn = "straight"
		

func turn_on_side_light() -> void:
	if turn == "right":
		right_side_light_timer.start()
	elif  turn == "left":
		left_side_light_timer.start()


func _on_side_light_timer_timeout() -> void:
	value_right = (value_right + 1) % 2
	if value_right == 1:
		right_side_light.color = Color.RED
		right_side_light.modulate.a = 1.0		
	else:
#		right_side_light.color = Color.BLACK
		right_side_light.modulate.a = 0.0


func _on_left_side_light_timer_timeout():
	value_left = (value_left + 1) % 2
	if value_left == 1:
		left_side_light.color = Color.RED
		left_side_light.modulate.a = 1.0		
	else:
		left_side_light.modulate.a = 0.0


func _on_car_side_area_body_entered(p_body) -> void:
	if p_body is Person:
		p_body.stop()


func _on_car_side_area_body_exited(p_body) -> void:
	if p_body is Person:
		p_body.move()


#func _on_ambulance_detection_area_body_entered(p_body) -> void:
##	if p_body is Ambulance:
##		print("Ambulance Entered=",p_body)
##		temp_velocity = Vector2(10,-10)
##		rotation = lerp_angle(rotation,velocity.angle(),5.0 * get_physics_process_delta_time())
#	var some_distance_to_the_left = 10.0
#	if p_body is Ambulance:
#
#		print("Ambulance Entered =", p_body)
#
#		# Calculate the direction from the car to the ambulance
#		var direction_to_ambulance = p_body.global_position - global_position
#		direction_to_ambulance = direction_to_ambulance.normalized()
#
#		# Calculate a target position to move the car to the left of the ambulance
#		side_movement_target = global_position + direction_to_ambulance * some_distance_to_the_left
#
#		move_sideways = true
#		brake_car(true)
#		velocity = Vector2.ZERO


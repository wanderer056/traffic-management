extends CharacterBody2D


signal ambulance_reached(p_ambu)

@export var steer_force = 0.1
@export var look_ahead = 100
@export var num_rays = 8
@export var destination: Marker2D
@export var max_speed: int = 300

var patient

@onready var available_destinations=get_tree().get_nodes_in_group("available_destinations") 
@onready var navigation_agent = $NavigationAgent2D

var ray_directions = []
var interest = []
var danger = []
var destination_pos

var chosen_dir = Vector2.ZERO
var _velocity = Vector2.ZERO

func _ready() -> void:
	if destination != null:
		navigation_agent.target_position = destination.global_position
	else:
		navigation_agent.target_position = destination_pos
	velocity = Vector2.ZERO
	
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)



func _physics_process(p_delta) ->void:
	if navigation_agent.is_navigation_finished():
		return


	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = chosen_dir.rotated(rotation) * max_speed
	_velocity = _velocity.lerp(desired_velocity, steer_force)
	rotation = _velocity.angle()
	navigation_agent.set_velocity(_velocity)

	move_and_collide(_velocity * p_delta)	


func set_interest():
	# Set interest in each slot based on world direction
	if self.has_method("get_path_direction"):
		var path_direction = get_path_direction()
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	# If no world path, use default interest
	else:
		set_default_interest()

func get_path_direction():
	return global_position.direction_to(navigation_agent.get_next_path_position())
#	return agent.get_next_path_position()

func set_default_interest():
	# Default to moving forward
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)

func set_danger():
	# Cast rays to find danger directions
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()



	for i in num_rays:
		params.from = position
		params.to = position + ray_directions[i].rotated(rotation) * look_ahead
		params.exclude = []
		var result = space_state.intersect_ray(params)

		danger[i] = 1.0 if result else 0.0

func choose_direction():
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
	


func _on_navigation_agent_2d_navigation_finished() -> void:
	await get_tree().create_timer(1.5).timeout
	patient.queue_free()
#	queue_free()
	var current_destination
	var mini_dist = 9999999 
	for dest in available_destinations:
		var distance = global_position.distance_to(dest.global_position)
		if  distance < mini_dist:
			current_destination = dest
			mini_dist = distance
	navigation_agent.target_position = current_destination.global_position

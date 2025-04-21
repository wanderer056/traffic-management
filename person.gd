extends CharacterBody2D

@export var destination: Marker2D

var speed = 50.0
var reached: bool = false
var spawn_pos
var id_string
var destination_offset: Vector2

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	if (destination.name == "TR" and spawn_pos.name == "TL") or  (destination.name == "BR" and spawn_pos.name == "BL"):
		rotate_collision()
	elif (destination.name == "TL" and spawn_pos.name == "TR") or  (destination.name == "BL" and spawn_pos.name == "BR"):
		rotate_collision()
		
	set_destination_offset_vector()

func _physics_process(p_delta) -> void:
	
#	var direction = global_position.direction_to($Marker2D.global_position)
#	if direction:
#		velocity = direction * SPEED
#		play_walk_animation(true)
#
	if global_position.distance_to(destination.global_position) < 10:
#		play_walk_animation(false)
#		return
		pass


		
	var direction = global_position.direction_to(destination.global_position+destination_offset)
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * p_delta * 4.0
		
	velocity += steering

	play_walk_animation(true)
	
	move_and_slide()
	

func play_walk_animation(p_walk:bool) -> void:
	if p_walk:
		if (destination.name == "TL" and spawn_pos.name == "BL") or (destination.name == "TR" and spawn_pos.name == "BR"):
			animated_sprite.play("walk_down_top")
		elif (destination.name == "BL" and spawn_pos.name == "TL") or (destination.name == "BR" and spawn_pos.name == "TR"):
			animated_sprite.play("walk_top_down")
		elif (destination.name == "TR" and spawn_pos.name == "TL") or  (destination.name == "BR" and spawn_pos.name == "BL"):
			animated_sprite.play("walk_left_right")
		elif (destination.name == "TL" and spawn_pos.name == "TR") or  (destination.name == "BL" and spawn_pos.name == "BR"):
			animated_sprite.play("walk_right_left")
			
	else:
		animated_sprite.play("pause_down_top")


func rotate_collision() -> void:
	$CollisionShape2D.rotation_degrees = 90


func set_destination_offset_vector() -> void:
	if destination.name == "TL" or destination.name == "TR":
		destination_offset = Vector2(0,-1000)
		
	elif destination.name == "BL" or destination.name == "BR":
		destination_offset = Vector2(0,1000)

	elif destination.name == "TR" or destination.name == "BR":
		destination_offset = Vector2(1000,0)
	
	elif destination.name == "TL" or destination.name == "BL":
		destination_offset = Vector2(-1000,0)

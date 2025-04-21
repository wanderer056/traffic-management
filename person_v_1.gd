class_name Person extends CharacterBody2D

@export var destination: Vector2
@export var speed = 90
#randf_range(80,110)

var v_velocity =  Vector2.ZERO
var prev_velocity
var move_dierction: String
var character: int
var rotation_set_from_another: bool = false
var talking: bool = false
var in_family: bool = false
var family_leader

@onready var animation_player = $AnimationPlayer
@onready var test_label = $Label
@onready var person_vision_area = $Area2D
@onready var talk_timer = $TalkTimer
@onready var sprite = $Sprite2D
@onready var collide_timer = $CollideTimer


func _ready() -> void:
	if not in_family:
		var characters = [9,10,11,12,13,14,15,16,17]
		character = characters.pick_random()
		test_label.text = str(character)
		set_collision_layer_value(character,true)
		set_collision_mask_value(character,true)
	#	person_vision_area.set_collision_layer_value(character,true)
		person_vision_area.set_collision_mask_value(character,true)

func _physics_process(p_delta) -> void:
	
	if velocity != Vector2.ZERO:
		play_animation(true)
	else:
		play_animation(false)
	var collision = move_and_collide(velocity*p_delta)
#	if collision != null:
#		var collider = collision.get_collider()
#		if collider is CarBase:
#			velocity = Vector2.ZERO
#			if collide_timer.time_left == 0:
#				collide_timer.start()
#			print("COLLIDED WITH CAR")
	
	if in_family:
		if is_instance_valid(family_leader):
			velocity = family_leader.velocity
			move_dierction = family_leader.move_dierction
		


func play_animation(p_walk:bool) -> void:
	if p_walk:
#		animated_sprite.play("walking")
		animation_player.play("walk")

	else:
#		animated_sprite.play("pause")
		animation_player.stop()


func move_right() -> void:
	rotation_degrees = 90
	velocity = Vector2(speed,0)

func move_left() -> void:
	rotation_degrees = -90
	velocity = Vector2(-speed,0)
	
func move_up() -> void:
	rotation_degrees = 0
	velocity = Vector2(0,-speed)

func move_down() -> void:
	rotation_degrees = 180
	velocity = Vector2(0,speed)

func stop() -> void:
	velocity = Vector2.ZERO

func move() -> void:
	if move_dierction == "right":
		move_right()
	elif move_dierction =="left":
		move_left()
	elif move_dierction == "up":
		move_up()
	elif move_dierction == "down":
		move_down()


func set_vision_area_collision_mask(p_character,p_set:bool) -> void:
	person_vision_area.set_collision_mask_value(p_character,p_set)

func _on_area_2d_body_entered(p_body) -> void:
	if p_body is CarBase:
		stop()
	elif p_body is Person:
		talk(p_body)
		await get_tree().create_timer(4).timeout
		stop_talking(p_body)


func _on_area_2d_body_exited(p_body) -> void:
	if p_body is CarBase:
		await get_tree().create_timer(1.5).timeout
		move()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_talk_timer_timeout() -> void:
	person_vision_area.set_collision_mask_value(character,false)
	set_collision_mask_value(character,false)		
	move()
	
func talk(p_body) -> void:
	stop()
	if !talking:
		p_body.stop()
		p_body.look_at(global_position)
		p_body.rotation_degrees += 90
		rotation_set_from_another = true
		look_at(p_body.global_position)
		rotation_degrees += 90	
		talking = true
	
	
func stop_talking(p_body) -> void:
	set_vision_area_collision_mask(character,false)
	set_collision_mask_value(character,false)
	if is_instance_valid(p_body):
		p_body.set_vision_area_collision_mask(character,false)
		p_body.set_collision_mask_value(character,false)
		p_body.move()		
	move()

func get_body_sprite():
	return sprite.texture


func _on_collide_timer_timeout() -> void:
	move()

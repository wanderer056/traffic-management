extends Node2D

@export var car_scenes : Array[PackedScene] = []
@export var person_scene: Array[PackedScene] =[]
@export var dead_man_scene: PackedScene
@export var ambu_scence: PackedScene

var car
var available_lane_dict = {"LP1":["TP1","RP1","BP2"],"LP2":["RP2","TP1","BP2"],"LP3":["RP3","TP1","BP2"],"LP4":["RP4","BP2"],"RP5":["LP5","TP1"],"RP6":["LP6"],"RP7":["LP7"],"RP8":["BP2"],"TP2":["RP1","BP2"],"BP1":["LP8","TP1"]}
var light_lane_map = {"left" : 0, "top": 1, "right":2, "bottom": 3}
var pers_dest_map = {"TL":["BL","TR"],"TR":["TL","BR"],"BL":["TL","BR"],"BR":["TR","BL"]}
var traffic_person_area_map = {0:1}
var person

@onready var paths = get_tree().get_nodes_in_group("paths")
@onready var traffic_lights = get_tree().get_nodes_in_group("traffic_lights")
@onready var road = $Road
@onready var person_container = $PersonContainer
@onready var bottom_person_spawn_pos = $PersonSpawnMarker/BL
@onready var top_person_spawn_pos = $PersonSpawnMarker/TR
@onready var ambulance_nav_region = $AmbulanceNavigationRegion


func _ready() -> void:
	print($RightLaneMarker.get_children()[0].name)


func _process(p_delta) -> void:
#	Engine.time_scale = 2.0
	pass


func _on_car_spawn_timer_timeout() -> void:
	
	if $NavigationRegion2D.get_child_count() < 100:
	
		var all_lane_pos = get_tree().get_nodes_in_group("positions")
		
		car = car_scenes.pick_random().instantiate()
		var current_spawn_position = get_tree().get_nodes_in_group("left_spawn_pos").pick_random()
		car.global_position = current_spawn_position.global_position
		car.spawn_pos_node = current_spawn_position
		
		var current_destination_name = available_lane_dict[current_spawn_position.name].pick_random()
		for pos in all_lane_pos:
			if pos.name ==current_destination_name:
				car.destination = pos
				break
		
		if "LP" in current_spawn_position.name:
			car.set_collision_layer_value(2,true)	
			car.spawn_pos = "left"
			
		elif "RP" in current_spawn_position.name:
			car.set_collision_layer_value(3,true)
			car.set_collision_layer_value(2,false)
			car.spawn_pos = "right"
			
		elif "TP" in current_spawn_position.name:
			car.set_collision_layer_value(4,true)
			car.set_collision_layer_value(2,false)
			car.set_collision_layer_value(3,false)
			car.spawn_pos = "top"
			
		elif "BP" in current_spawn_position.name:
			car.set_collision_layer_value(5,true)
			car.set_collision_layer_value(4,false)
			car.set_collision_layer_value(2,false)
			car.set_collision_layer_value(3,false)
			car.spawn_pos = "bottom"
		
		$NavigationRegion2D.add_child(car)
		car.person_hit.connect(_on_person_hit)

func _on_person_hit(p_collider) -> void:
	var dead_man = dead_man_scene.instantiate()
	dead_man.global_position = p_collider.global_position
#	dead_man.set_body_texture(p_collider.get_body_sprite())
	p_collider.queue_free()
	person_container.add_child(dead_man)
	call_ambulance(dead_man)
	

func _on_road_left_zebra_entered(p_body) -> void:
		if p_body is CarBase and ! p_body.special_cases:
			var current_tf_lght = traffic_lights[light_lane_map[p_body.spawn_pos]]
			if current_tf_lght.current_light =="red" or current_tf_lght.current_light == "yellow" :
				p_body.brake_car(true)

#
func _on_traffic_manager_traffic_light_changed() -> void:

	for ind in range(0,len(traffic_lights)):
		if traffic_lights[ind].current_light == "green":
			var bodies_list = road.get_overlapping_body(ind)
			for body in bodies_list:
				body.brake_car(false)
		
		if traffic_lights[ind].current_light == "red":
			if(len(road.get_overlapping_person(ind))>0):
				var persons = road.get_overlapping_person(ind)
				for person in persons:
					person.move()



func _on_timer_timeout():
	var spawn_pos
	person = person_scene.pick_random().instantiate()
	var av_spawn_pos = get_tree().get_nodes_in_group("person_spawn_area")
	var current_spawn_pos = av_spawn_pos.pick_random()
	spawn_pos = current_spawn_pos.global_position
#	spawn_pos= bottom_person_spawn_pos.global_position
	
	if current_spawn_pos.name == "TL" or current_spawn_pos.name == "BR":
		spawn_pos.x = randf_range(spawn_pos.x,spawn_pos.x + 150)
	person.global_position = spawn_pos
	
	if current_spawn_pos.name == "TL":
		person.move_dierction = "down"
	elif current_spawn_pos.name == "BR":
		person.move_dierction = "up"
	person.move()
	person_container.add_child(person)
	


func _on_road_person_waiting_zebra_1(p_area):
	if traffic_lights[3].current_light != "red":
		p_area.get_parent().stop()


func _on_road_person_entered_in_bottom_zebra_limit(p_body):
	if traffic_lights[0].current_light != "red":
		p_body.stop()


func _on_road_person_entered_in_top_zebra_limit(p_body):
	if traffic_lights[2].current_light != "red":
		p_body.stop()


func _on_person_spawn_timer_2_timeout():
	var spawn_pos
	person = person_scene.pick_random().instantiate()
	var av_spawn_pos = get_tree().get_nodes_in_group("person_spawn_area2")
	var current_spawn_pos = av_spawn_pos.pick_random()
	spawn_pos = current_spawn_pos.global_position
#	spawn_pos= bottom_person_spawn_pos.global_position
	
	spawn_pos.y = randf_range(spawn_pos.y,spawn_pos.y + 150)
	person.global_position = spawn_pos
	
	if current_spawn_pos.name == "TR":
		person.move_dierction = "left"
	elif current_spawn_pos.name == "BL":
		person.move_dierction = "right"
	person.move()
	person_container.add_child(person)


func _on_road_person_entered_in_left_zebra_limit(p_body) -> void:
	if traffic_lights[3].current_light != "red":
		p_body.stop()


func _on_road_person_entered_in_right_zebra_limit(p_body) -> void:
	if traffic_lights[1].current_light != "red":
		p_body.stop()


func _on_family_spawn_timer_timeout()-> void:
	var family_persons_scene = []
	var spawn_pos
	var persons = []
	family_persons_scene.append(person_scene[1])
	family_persons_scene.append(person_scene[2])
	family_persons_scene.append(person_scene[5])
	
	for fam in family_persons_scene:
		persons.append(fam.instantiate())
	
	var av_spawn_pos = get_tree().get_nodes_in_group("person_spawn_area2")
	av_spawn_pos.append_array(get_tree().get_nodes_in_group("person_spawn_area"))
	
	var current_spawn_pos = av_spawn_pos.pick_random()
	spawn_pos = current_spawn_pos.global_position
	
	if current_spawn_pos.name == "TL" or current_spawn_pos.name == "BR":
		spawn_pos.x = randf_range(spawn_pos.x+40,spawn_pos.x + 150 - 40)
	else:
		spawn_pos.y = randf_range(spawn_pos.y+40,spawn_pos.y + 150 - 40)
		
	for person in persons:
		person.global_position = spawn_pos + Vector2(randi_range(-40,40),randi_range(-40,40))
	
		if current_spawn_pos.name == "TL":
			person.move_dierction = "down"
		elif current_spawn_pos.name == "BR":
			person.move_dierction = "up"
		elif current_spawn_pos.name == "TR":
			person.move_dierction = "left"
		elif current_spawn_pos.name == "BL":
			person.move_dierction = "right"
		
		person.in_family= true
		person.family_leader = persons[0]
		person.speed = 60.0
		person.move()
		person_container.add_child(person)

func call_ambulance(p_body) -> void:
	var ambulance = ambu_scence.instantiate()
	var current_spawn_position = get_tree().get_nodes_in_group("left_spawn_pos").pick_random()
	ambulance.global_position = current_spawn_position.global_position
	ambulance.patient = p_body
	ambulance.destination_pos = p_body.global_position
#	ambulance.spawn_pos_node = current_spawn_position
	
	$NavigationRegion2D.add_child(ambulance)
	print("Ambulance Called")
	

extends Node2D

signal left_zebra_entered(p_body)
signal person_waiting_zebra(p_body)
signal person_waiting_zebra_1(p_area)
signal person_entered_in_bottom_zebra_limit(p_body)
signal person_entered_in_top_zebra_limit(p_body)
signal person_entered_in_left_zebra_limit(p_body)
signal person_entered_in_right_zebra_limit(p_body)


@onready var left_zebra = $LeftZebra
@onready var top_zebra = $TopZebra
@onready var right_zebra = $RightZebra
@onready var bottom_zebra = $BottomZebra
@onready var bottom_zebra_person = $BottomZebraPerson
@onready var bottom_zebra_person2 = $BottomZebraPerson2
@onready var top_zebra_person = $TopZebraPerson
@onready var top_zebra_person2 = $TopZebraPerson2
@onready var left_zebra_person = $LeftZebraPerson
@onready var left_zebra_person2 = $LeftZebraPerson2
@onready var right_zebra_person = $RightZebraPerson
@onready var right_zebra_person2 = $RightZebraPerson2



func _on_left_zebra_body_entered(p_body) -> void:
	left_zebra_entered.emit(p_body)


func _on_left_zebra_body_exited(p_body) -> void:
	if p_body is CarBase:
		p_body.set_zebra_corssed(true)


func get_overlapping_body(zebra: int):
	if zebra == 0:
		return left_zebra.get_overlapping_bodies()
	
	elif zebra == 1:
		return top_zebra.get_overlapping_bodies()
		
	elif zebra == 2:
		return right_zebra.get_overlapping_bodies()
		
	elif zebra == 3:
		return bottom_zebra.get_overlapping_bodies()



func _on_area_2d_body_entered(p_body):
	person_waiting_zebra.emit(p_body)


func get_overlapping_person(number):
	if number == 0:
		var all_persons = bottom_zebra_person.get_overlapping_bodies()
		all_persons.append_array(bottom_zebra_person2.get_overlapping_bodies())
		return all_persons
	elif number == 1:
		var all_persons = right_zebra_person.get_overlapping_bodies()
		all_persons.append_array(right_zebra_person2.get_overlapping_bodies())
		return all_persons
	elif number == 2:
		var all_persons = top_zebra_person.get_overlapping_bodies()
		all_persons.append_array(top_zebra_person2.get_overlapping_bodies())
		return all_persons
	elif number == 3:
		var all_persons = left_zebra_person.get_overlapping_bodies()
		all_persons.append_array(left_zebra_person2.get_overlapping_bodies())
		return all_persons

func _on_area_2d_area_entered(p_area):
	person_waiting_zebra_1.emit(p_area)


func _on_bottom_zebra_person_body_entered(p_body) -> void:
	if p_body is Person and p_body.move_dierction == "down":
		person_entered_in_bottom_zebra_limit.emit(p_body)
		
func _on_bottom_zebra_person_2_body_entered(p_body) -> void:
	if p_body is Person and p_body.move_dierction == "up":
		person_entered_in_bottom_zebra_limit.emit(p_body)
	

func _on_top_zebra_person_body_entered(p_body) -> void:
	if p_body is Person and p_body.move_dierction == "up":
		person_entered_in_top_zebra_limit.emit(p_body)


func _on_top_zebra_person_2_body_entered(p_body) -> void:
	if p_body is Person and p_body.move_dierction == "down":
		person_entered_in_top_zebra_limit.emit(p_body)


func _on_right_zebra_person_body_entered(p_body):
	if p_body is Person and p_body.move_dierction == "left":
		person_entered_in_right_zebra_limit.emit(p_body)


func _on_right_zebra_person_2_body_entered(p_body) -> void:
	if p_body is Person and p_body.move_dierction == "right":
		person_entered_in_right_zebra_limit.emit(p_body)


func _on_left_zebra_person_body_entered(p_body):
	if p_body is Person and p_body.move_dierction == "right":
		person_entered_in_left_zebra_limit.emit(p_body)


func _on_left_zebra_person_2_body_entered(p_body):
	if p_body is Person and p_body.move_dierction == "left":
		person_entered_in_left_zebra_limit.emit(p_body)


func _on_area_2d_2_body_entered(p_body):
	var dirs = ["left","right","up","down"]
	var rmv_dict = {"right":"left","left":"right","up":"down","down":"up"}
	if p_body is Person and not p_body.in_family:
		dirs.erase(rmv_dict[p_body.move_dierction])
		p_body.move_dierction = dirs.pick_random()
		p_body.move()
		
		





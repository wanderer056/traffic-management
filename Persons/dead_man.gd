extends Node2D


@onready var blood_sprite = $Blood
@onready var dead_body = $Body
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blood_sprite.play()




func _on_blood_animation_finished() -> void:
	blood_sprite.stop()



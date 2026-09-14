extends CharacterBody3D

signal attack

@export var speed = 14
@export var acceleration = 4.0
@export var fall_acceleration = 75
@export var rotation_speed = 12
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@onready var model := $CollisionShape3D as CollisionShape3D
@onready var spring_arm := $CameraPivot/SpringArm3D as SpringArm3D

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	#velocity.y += -gravity * delta
	get_move_input(delta)
	move_and_slide()
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	get_attack_input()
	

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy

func get_attack_input():
	if Input.is_action_pressed("attack"):
		velocity = Vector3.ZERO
		emit_signal("attack")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

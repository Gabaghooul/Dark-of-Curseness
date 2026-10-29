extends CharacterBody3D

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 100
@export var speed = 14
@export var acceleration = 3.0
@export var fall_acceleration = 75
@export var rotation_speed = 12
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@onready var model := $VisualPivot as Node3D
@onready var spring_arm := $CameraPivot/SpringArm3D as SpringArm3D

var target_velocity = Vector3.ZERO
var state = "READY"
var combo_buffered = false

func _ready():
	$Health.init(max_hp)
	$Health.damage_taken.connect(_on_damage_taken)

func _physics_process(delta):
	#velocity.y += -gravity * delta
	get_move_input(delta)
	move_and_slide()
	get_attack_input()

func get_move_input(delta):
	if state == "READY":
		var vy = velocity.y
		velocity.y = 0
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
		velocity = lerp(velocity, dir * speed, acceleration * delta)
		velocity.y = vy
		if velocity.length() > 1.0:
			if dir.length() > 0.0:
				var target_angle = atan2(dir.x, dir.z)
				model.rotation.y = lerp_angle(model.rotation.y, target_angle + 180, rotation_speed * delta)

func get_attack_input():
	if Input.is_action_just_pressed("attack"):
		if state == "READY":
			state = "ATTACK"
			velocity = Vector3.ZERO
			$VisualPivot/Pivot/WeaponSlot/Weapon.attack()
		elif state == "RECOVERY":
			state = "ATTACK"
			velocity = Vector3.ZERO
			$VisualPivot/Pivot/WeaponSlot/Weapon.attack()
		elif state == "ATTACK":
			combo_buffered = true

func enter_recovery():
	state = "RECOVERY"
	if combo_buffered:
		state = "ATTACK"
		velocity = Vector3.ZERO
		$VisualPivot/Pivot/WeaponSlot/Weapon.attack()
		combo_buffered = false

func reset_state():
	state = "READY"
	combo_buffered = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func hurt():
	state = "HURT"
	$AnimationPlayer.play("Hurt")
	$VisualPivot/Pivot/WeaponSlot/Weapon.interrupted()

func _on_damage_taken(amount: int):
	var number = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position + Vector3(0, 1, 0)
	number.show_damage(amount)

func death():
	#game over
	queue_free()

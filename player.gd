extends CharacterBody3D

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 100
@export var speed = 10
@export var acceleration = 10.0
@export var fall_acceleration = 75
@export var rotation_speed = 12
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@onready var model := $VisualPivot as Node3D
@onready var spring_arm := $CameraPivot/SpringArm3D as SpringArm3D

var target_velocity = Vector3.ZERO
var state = "READY"
var combo_buffered = false
var dodge_ready = true

func _ready():
	$Health.init(max_hp)
	$Health.damage_taken.connect(_on_damage_taken)
	$Health.block.connect(_on_damage_blocked)

func _physics_process(delta):
	#velocity.y += -gravity * delta
	get_move_input(delta)
	move_and_slide()
	get_attack_input()
	get_guard_input()
	get_dodge_input()

func get_move_input(delta):
	if state == "READY" || state == "GUARD":
		var vy = velocity.y
		velocity.y = 0
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
		if state == "GUARD":
			velocity = lerp(velocity, (dir * speed)/4, acceleration * delta)
		else:
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
		elif state == "ATTACK_RECOVERY":
			state = "ATTACK"
			velocity = Vector3.ZERO
			$VisualPivot/Pivot/WeaponSlot/Weapon.attack()
		elif state == "ATTACK":
			combo_buffered = true

func get_guard_input():
	if state == "READY" || state == "ATTACK_RECOVERY":
		if Input.is_action_pressed("guard"):
			state = "GUARD"
	if Input.is_action_just_released("guard"):
		reset_state()

func get_dodge_input():
	#deactivate hitbox during dodge
	if state == "GUARD" && Input.is_action_just_pressed("jump"):
		state = "DODGE"
		$AnimationPlayer.play("Dodge")

func dodge(delta):
	$Hurtbox.set_deferred("monitorable", false)
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, (dir * speed)*4, acceleration * delta * 4)
	if velocity.length() > 1.0:
		if dir.length() > 0.0:
			var target_angle = atan2(dir.x, dir.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_angle + 180, rotation_speed * delta)

func enter_attack_recovery():
	state = "ATTACK_RECOVERY"
	if combo_buffered:
		state = "ATTACK"
		velocity = Vector3.ZERO
		$VisualPivot/Pivot/WeaponSlot/Weapon.attack()
		combo_buffered = false

func enter_dodge_recovery():
	state = "READY"
	dodge_ready = false
	$Hurtbox.set_deferred("monitorable", true)

func reset_state():
	state = "READY"
	dodge_ready = true
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

func block():
	state = "BLOCK"
	$AnimationPlayer.play("Hurt")

func _on_damage_taken(amount: int):
	var number = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position + Vector3(0, 1, 0)
	number.show_damage(amount)
	
func _on_damage_blocked():
	var guard_text = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(guard_text)
	guard_text.global_position = global_position + Vector3(0, 1, 0)
	guard_text.show_block()

func death():
	#game over
	queue_free()

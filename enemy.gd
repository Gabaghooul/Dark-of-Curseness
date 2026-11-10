extends CharacterBody3D

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 250
@export var damage = 10
@export var speed = 4
@export var attack_range = 1.3
@export var rotation_speed = 20

var connected_hits = []
var state = "IDLE"

@onready var model := $VisualPivot as Node3D
@onready var timer: Timer = $Timer
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
var player = null
var direction = Vector3.ZERO

func _ready():
	player = get_tree().current_scene.get_node("Player")
	$Health.init(max_hp)
	$Health.damage_taken.connect(_on_damage_taken)
	
func _physics_process(delta):
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	direction = (player.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()
	decide_action(distance_to_player)
	execute_action(delta)
	move_and_slide()

func decide_action(distance_to_player):
	match state:
		"IDLE":
			if distance_to_player > attack_range:
				change_state("CHASE")
			elif distance_to_player <= attack_range:
				change_state("ATTACK")
			pass
		"CHASE":
			if distance_to_player <= attack_range:
				change_state("ATTACK")
			pass

func change_state(new_state):
	state = new_state
	match state:
		"IDLE", "COOLDOWN":
			playback.travel("Idle")
			pass
		"CHASE":
			playback.travel("Walk")
			pass
		"ATTACK":
			connected_hits = []
			playback.travel("Attack")
			pass
		"HURT":
			disable_hitbox()
			playback.travel("Hurt")
			pass

func execute_action(delta):
	match state:
		"CHASE":
			var target_angle = atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
			velocity = direction * speed
			pass
		"ATTACK":
			var target_angle = atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
			velocity = Vector3.ZERO
			pass
		"COOLDOWN":
			velocity = velocity.move_toward(Vector3.ZERO, speed * 0.1 * delta)
			pass
		"HURT":
			velocity = Vector3.ZERO
			pass

func _on_timeout() -> void:
	change_state("IDLE")

func on_attack_finished(anim_name):
	if anim_name == "Attack":
		timer.start()
		change_state("COOLDOWN")

func enable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", true)
	
func disable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", false)
	
func _on_hitbox_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	if target.has_node("Health") && !connected_hits.has(target):
		target.get_node("Health").take_damage(damage)
		connected_hits.append(target)

func hurt():
	change_state("HURT")

func _on_damage_taken(amount: int):
	var number = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position + Vector3(0, 1, 0)
	number.show_damage(amount)

func death():
	#give xp/roll for drops/etc
	queue_free()

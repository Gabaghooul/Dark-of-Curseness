extends CharacterBody3D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	COOLDOWN,
	HURT
}

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 250
@export var damage = 10
@export var speed = 4
@export var attack_range = 1.3
@export var rotation_speed = 20

var connected_hits: Array[Node] = []
var state: State = State.IDLE
var player: Node3D
var direction: Vector3 = Vector3.ZERO

@onready var facing_pivot: Node3D = $VisualPivot
@onready var hitbox: Area3D = $VisualPivot/Hitbox
@onready var health = $Health
@onready var cooldown_timer: Timer = $Timer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

func _ready():
	player = get_tree().current_scene.get_node_or_null("Player")
	
	health.init(max_hp)
	health.damage_taken.connect(_on_damage_taken)
	cooldown_timer.one_shot = true
	
func _physics_process(delta):
	if not is_instance_valid(player):
		return
	
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()
	direction = to_player.normalized() if distance > 0.001 else Vector3.ZERO
	
	_update_state(distance)
	_update_movement(delta)
	
	move_and_slide()

func _update_state(distance):
	match state:
		State.IDLE:
			if distance > attack_range:
				change_state(State.CHASE)
			else:
				change_state(State.ATTACK)

		State.CHASE:
			if distance <= attack_range:
				change_state(State.ATTACK)


func change_state(new_state: State):
	if state == new_state:
		return

	if state == State.ATTACK:
		disable_hitbox()

	if new_state == State.HURT:
		cooldown_timer.stop()

	state = new_state

	match state:
		State.IDLE:
			playback.travel("Idle")
		State.CHASE:
			playback.travel("Walk")
		State.ATTACK:
			connected_hits.clear()
			playback.travel("Attack")
		State.COOLDOWN:
			cooldown_timer.start()
			playback.travel("Idle")
		State.HURT:
			disable_hitbox()
			playback.travel("Hurt")

func _update_movement(delta):
	match state:
		State.CHASE:
			_face_player(delta)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		State.ATTACK:
			_face_player(delta)
			velocity.x = 0.0
			velocity.z = 0.0
		_:
			velocity.x = 0.0
			velocity.z = 0.0

func _face_player(delta):
	if direction.length_squared() < 0.001:
		return
	
	var target_angle := atan2(direction.x, direction.z)
	var weight := minf(rotation_speed * delta, 1.0)
	facing_pivot.rotation.y = lerp_angle(facing_pivot.rotation.y, target_angle, weight)

func _on_timeout() -> void:
	if state == State.COOLDOWN:
		change_state(State.IDLE)

func _on_animation_finished(anim_name):
	if state == State.ATTACK && anim_name == "Attack":
		change_state(State.COOLDOWN)
	elif state == State.HURT && anim_name == "Hurt":
		cooldown_timer.start()
		change_state(State.COOLDOWN)

func enable_hitbox():
	if state == State.ATTACK:
		hitbox.set_deferred("monitoring", true)
	
func disable_hitbox():
	hitbox.set_deferred("monitoring", false)
	
func _on_hitbox_area_entered(area: Area3D) -> void:
	if state != State.ATTACK:
		return

	var target = area.get_parent()
	if target == null:
		return

	if target.has_node("Health") && !connected_hits.has(target):
		target.get_node("Health").take_damage(damage)
		connected_hits.append(target)

func hurt():
	change_state(State.HURT)

func _on_damage_taken(amount: int):
	var number = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position + Vector3(0, 1, 0)
	number.show_damage(amount)

func death():
	cooldown_timer.stop()
	disable_hitbox()
	#give xp/roll for drops/etc
	queue_free()

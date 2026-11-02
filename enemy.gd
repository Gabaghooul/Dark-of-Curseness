extends CharacterBody3D

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 250
@export var damage = 10
@export var speed = 4
@export var attack_range = 1.3

var connected_hits = []
var state = "CHASE"

@onready var model := $VisualPivot as Node3D
@onready var timer: Timer = $Timer
var player = null

func _ready():
	player = get_tree().current_scene.get_node("Player")
	$Health.init(max_hp)
	$Health.damage_taken.connect(_on_damage_taken)
	
func _physics_process(delta):
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	decide_action(distance_to_player)
	execute_action()
	move_and_slide()

func decide_action(distance_to_player):
	match state:
		"CHASE":
			if distance_to_player <= attack_range:
				state = "ATTACK"
		"ATTACK":
			pass
		"COOLDOWN":
			pass

func execute_action():
	match state:
		"CHASE":
			var direction = (player.global_position - global_position).normalized()
			model.rotation.y = direction.y
			velocity = direction * speed
		"ATTACK":
			var direction = (player.global_position - global_position).normalized()
			model.rotation.y = direction.y
			velocity = Vector3.ZERO
			attack()
		"COOLDOWN":
			velocity = velocity.move_toward(Vector3.ZERO, speed * 0.1)

func _on_timeout() -> void:
	state = "CHASE"

func attack():
	connected_hits = []
	$AnimationPlayer.play("Attack")
	state = "COOLDOWN"
	
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
	timer.start()
	$AnimationPlayer.play("Hurt")
	
func _on_damage_taken(amount: int):
	var number = DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position + Vector3(0, 1, 0)
	number.show_damage(amount)

func death():
	#give xp/roll for drops/etc
	queue_free()

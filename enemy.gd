extends CharacterBody3D

const DAMAGE_NUMBER = preload("res://ui/damage_numbers.tscn")

@export var max_hp = 250
@export var damage = 10
var connected_hits = []

@onready var timer: Timer = $Timer

func _ready():
	$Health.init(max_hp)
	$Health.damage_taken.connect(_on_damage_taken)

func _on_timeout() -> void:
	attack()

func attack():
	connected_hits = []
	$AnimationPlayer.play("Attack")
	
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

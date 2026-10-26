extends CharacterBody3D

@export var max_hp = 50
@export var damage = 10
var connected_hits = []

@onready var timer: Timer = $Timer

func _ready():
	$Health.init(max_hp)

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
		
func death():
	#give xp/roll for drops/etc
	queue_free()

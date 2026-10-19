extends CharacterBody3D

@export var hp = 100
@export var damage = 10
var connected_hits = []

@onready var timer: Timer = $Timer

func _on_timeout() -> void:
	attack()

func take_damage(incoming_damage):
	if hp > 0:
		$AnimationPlayer.play("Hurt")
		hp -= incoming_damage
		print("Enemy hit: ", hp, "/", 100)
	if hp <= 0:
		queue_free()
		print("Enemy dead")
		
func attack():
	connected_hits = []
	$AnimationPlayer.play("Attack")
	
func enable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", true)
	
func disable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", false)
	
func _on_hitbox_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	if target.has_method("take_damage") && !connected_hits.has(target):
		target.take_damage(damage)
		connected_hits.append(target)

extends Node3D

@export var damage = 10
var connected_hits = []

func attack():
	connected_hits = []	
	$AnimationPlayer.play("swing")
	
func enable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", true)
	
func finish_attack():
	$VisualPivot/Hitbox.set_deferred("monitoring", false)

func _on_hitbox_area_entered(area: Area3D) -> void:
	var enemy = area.get_parent().get_parent()
	if enemy.has_method("take_damage") && !connected_hits.has(enemy):
		enemy.take_damage(damage)
		connected_hits.append(enemy)
